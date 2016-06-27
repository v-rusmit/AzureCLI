#Requires -Version 3.0
#Requires -Module AzureRM.Resources
#Requires -Module Azure.Storage

Param(
    [string] [Parameter(Mandatory=$true)] $ResourceGroupLocation,
    [string] [Parameter(Mandatory=$true)] $ResourceGroupName,
    [switch] $UploadArtifacts = $true,

    [string] $StorageAccountName,
    [string] $StorageContainerName       = $ResourceGroupName.ToLowerInvariant() + '-stageartifacts',
    [string] $StorageContainerNameCommon = 'common'                              + '-stageartifacts',

    [string] $TemplateFile             = '..\Templates\azuredeploy.json',
    [string] $TemplateParametersFile   = '..\Templates\azuredeploy.parameters.json',

    [string] $ArtifactStagingDirectory = '..\bin\Debug\staging',

    [string] $TemplatesFolder       = '..\Templates',  
    [string] $TemplatesFolderCommon = '..\..\0-Common\Templates',

    [string] $CSESourceFolder       = '..\CSE',
    [string] $CSESourceFolderCommon = '..\..\0-Common\CSE',

    [string] $DSCSourceFolder       = '..\DSC',
    [string] $DSCSourceFolderCommon = '..\..\0-Common\DSC'
)

Import-Module Azure -ErrorAction SilentlyContinue
Add-Type -Assembly System.IO.Compression.FileSystem

try  {Get-AzureRmResourceGroup >$null}
catch{Login-AzureRmAccount -ErrorAction Stop }

try {
    [Microsoft.Azure.Common.Authentication.AzureSession]::ClientFactory.AddUserAgent("VSAzureTools-$UI$($host.name)".replace(" ","_"), "2.9")
} catch { }

Set-StrictMode -Version 3

if ($StorageAccountName -eq "")     #if this storage account is specified, it is presumed to exist!
{
    do {  
        $StorageAccountName = [Guid]::NewGuid().ToString() 
        $StorageAccountName = $StorageAccountName.Replace("-", "").Substring(0, 23) 
        $isAvail = Get-AzureRmStorageAccountNameAvailability -Name $StorageAccountName | Select-Object -ExpandProperty NameAvailable 
    } while (!$isAvail) 

    $ResourceGroupName_artifact = "ARMTemplateDemo"
    Write-Host -BackgroundColor Magenta "Creating artifact storage $StorageAccountName in resource group ARMTemplateDemo"
    New-AzureRmResourceGroup                                         -Name $ResourceGroupName_artifact -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop
    New-AzureRmStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName_artifact -Location $ResourceGroupLocation -Type Standard_LRS
}
else
{
    Write-Host -BackgroundColor Magenta "Using artifact storage $StorageAccountName"
}



$OptionalParameters = New-Object -TypeName Hashtable
$TemplateFile           = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateFile))
$TemplateParametersFile = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplateParametersFile))

if ($UploadArtifacts) {

    # Convert relative paths to absolute paths if needed
    $ArtifactStagingDirectory = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $ArtifactStagingDirectory))
    $CSESourceFolder          = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $CSESourceFolder))
    $CSESourceFolderCommon    = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $CSESourceFolderCommon))
    $DSCSourceFolder          = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $DSCSourceFolder))
    $DSCSourceFolderCommon    = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $DSCSourceFolderCommon))
    $TemplatesFolder          = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplatesFolder))
    $TemplatesFolderCommon    = [System.IO.Path]::GetFullPath([System.IO.Path]::Combine($PSScriptRoot, $TemplatesFolderCommon))

    Set-Variable ArtifactsLocationName         '_artifactsLocation'         -Option ReadOnly -Force
    Set-Variable ArtifactsLocationSasTokenName '_artifactsLocationSasToken' -Option ReadOnly -Force

    $OptionalParameters.Add($ArtifactsLocationName,         $null)
    $OptionalParameters.Add($ArtifactsLocationSasTokenName, $null)

    # Parse the parameter file and update the values of artifacts location and artifacts location SAS token if they are present
    $JsonContent = Get-Content $TemplateParametersFile -Raw | ConvertFrom-Json
    $JsonParameters = $JsonContent | Get-Member -Type NoteProperty | Where-Object {$_.Name -eq "parameters"}

    if ($JsonParameters -eq $null) { $JsonParameters = $JsonContent }
    else                           { $JsonParameters = $JsonContent.parameters }

    $JsonParameters | Get-Member -Type NoteProperty | ForEach-Object {
        $ParameterValue = $JsonParameters | Select-Object -ExpandProperty $_.Name
        if ($_.Name -eq $ArtifactsLocationName -or $_.Name -eq $ArtifactsLocationSasTokenName) { $OptionalParameters[$_.Name] = $ParameterValue.value }
    }


    $StorageAccountContext = (Get-AzureRmStorageAccount | Where-Object{$_.StorageAccountName -eq $StorageAccountName}).Context

    # Generate the value for artifacts location if it is not provided in the parameter file
    $ArtifactsLocation = $OptionalParameters[$ArtifactsLocationName]
    if ($ArtifactsLocation -eq $null) {
        $ArtifactsLocation = $StorageAccountContext.BlobEndPoint + $StorageContainerName
        $OptionalParameters[$ArtifactsLocationName] = $ArtifactsLocation
    }






    # Create (or skip if already created) containers for all the files we need to upload
    New-AzureStorageContainer -Name $StorageContainerName       -Context $StorageAccountContext -Permission Container -ErrorAction SilentlyContinue 
    New-AzureStorageContainer -Name $StorageContainerNameCommon -Context $StorageAccountContext -Permission Container -ErrorAction SilentlyContinue 

	# Copy template files from THIS PROJECT to the storage account container
    $ArtifactFilePaths = Get-ChildItem $TemplatesFolder -Recurse -File | ForEach-Object -Process {$_.FullName} 
    foreach ($SourcePath in $ArtifactFilePaths) {
	    Write-Host -BackgroundColor DarkCyan $SourcePath
	    $BlobName = $SourcePath.Substring($TemplatesFolder.length + 1) 
        Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerName -Context $StorageAccountContext -Force >$null
    }
	
	# Copy template files from the COMMON PROJECT to the storage account container
    $ArtifactFilePaths = Get-ChildItem $TemplatesFolderCommon -Recurse -File | ForEach-Object -Process {$_.FullName} 
    foreach ($SourcePath in $ArtifactFilePaths) {
	    Write-Host -BackgroundColor DarkCyan $SourcePath
	    $BlobName = $SourcePath.Substring($TemplatesFolderCommon.length + 1) 
        Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerNameCommon -Context $StorageAccountContext -Force >$null
    }

	# Copy CSE files from THIS PROJECT to the storage account container
    if (Test-Path $CSESourceFolder) {
		$ArtifactFilePaths = Get-ChildItem $CSESourceFolder -Recurse -File | ForEach-Object -Process {$_.FullName} 
		foreach ($SourcePath in $ArtifactFilePaths) {
			Write-Host -BackgroundColor DarkCyan $SourcePath
			$BlobName = $SourcePath.Substring($CSESourceFolder.length + 1) 
			Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerNameCommon -Context $StorageAccountContext -Force >$null
		}
    }

	# Copy CSE files from the COMMON PROJECT to the storage account container
    if (Test-Path $CSESourceFolderCommon) {
		$ArtifactFilePaths = Get-ChildItem $CSESourceFolderCommon -Recurse -File | ForEach-Object -Process {$_.FullName} 
		foreach ($SourcePath in $ArtifactFilePaths) {
			Write-Host -BackgroundColor DarkCyan $SourcePath
			$BlobName = $SourcePath.Substring($CSESourceFolderCommon.length + 1) 
			Set-AzureStorageBlobContent -File $SourcePath -Blob $BlobName -Container $StorageContainerNameCommon -Context $StorageAccountContext -Force >$null
		}
    }

	# Create DSC configuration archive from THIS PROJECT
    if (Test-Path $DSCSourceFolder) {
		$BlobName = "dsc.zip"
        $ArchiveFile = Join-Path $ArtifactStagingDirectory $BlobName
        Remove-Item -Path $ArchiveFile -ErrorAction SilentlyContinue
        [System.IO.Compression.ZipFile]::CreateFromDirectory($DSCSourceFolder, $ArchiveFile)
        Set-AzureStorageBlobContent -File $ArchiveFile -Blob $BlobName -Container $StorageContainerName -Context $StorageAccountContext -Force >$null
	    Write-Host -BackgroundColor DarkCyan $ArchiveFile
    }

	# Create DSC configuration archive from COMMON PROJECT
    if (Test-Path $DSCSourceFolderCommon) {
		$BlobName = "dsccommon.zip"
        $ArchiveFile = Join-Path $ArtifactStagingDirectory $BlobName
        Remove-Item -Path $ArchiveFile -ErrorAction SilentlyContinue
        [System.IO.Compression.ZipFile]::CreateFromDirectory($DSCSourceFolderCommon, $ArchiveFile)
        Set-AzureStorageBlobContent -File $ArchiveFile -Blob $BlobName -Container $StorageContainerNameCommon -Context $StorageAccountContext -Force >$null
	    Write-Host -BackgroundColor DarkCyan $ArchiveFile
    }






    # Generate the value for artifacts location SAS token if it is not provided in the parameter file
    $ArtifactsLocationSasToken = $OptionalParameters[$ArtifactsLocationSasTokenName]
    if ($ArtifactsLocationSasToken -eq $null) {
        # Create a SAS token for the storage container - this gives temporary read-only access to the container
        $ArtifactsLocationSasToken = New-AzureStorageContainerSASToken -Container $StorageContainerName -Context $StorageAccountContext -Permission r -ExpiryTime (Get-Date).AddHours(4)
        $ArtifactsLocationSasToken = ConvertTo-SecureString $ArtifactsLocationSasToken -AsPlainText -Force
        $OptionalParameters[$ArtifactsLocationSasTokenName] = $ArtifactsLocationSasToken
    }


}

# Create or update the resource group using the specified template file and template parameters file
New-AzureRmResourceGroup -Name $ResourceGroupName -Location $ResourceGroupLocation -Verbose -Force -ErrorAction Stop 

New-AzureRmResourceGroupDeployment -Name ((Get-ChildItem $TemplateFile).BaseName + '-' + ((Get-Date).ToUniversalTime()).ToString('MMdd-HHmm')) `
                                   -ResourceGroupName $ResourceGroupName `
                                   -TemplateFile $TemplateFile `
                                   -TemplateParameterFile $TemplateParametersFile `
                                   @OptionalParameters `
									-Force -Verbose
