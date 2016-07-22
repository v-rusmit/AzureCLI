Configuration DemoSQL
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
										                              [string] $SampleAppLocation,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount,

		[String]$DomainNetbiosName  = (Get-NetBIOSName -DomainName $domain),
		[UInt32]$DatabaseEnginePort = 1433,
		   [Int]$RetryCount         = 20,
		   [Int]$RetryIntervalSec   = 30
)
	
	Import-DscResource -Module xStorage
	Import-DscResource -Module cDisk
	Import-DscResource -Module xComputerManagement
	Import-DscResource -Module xSmbShare
	
	$ClusterName  = $DomainNetbiosName + 'Cluster'
	$SharePath    = $ClusterName


	Node localhost
	{
		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
		}

		xWaitforDisk Disk2                               # Make Sure Disk is Ready
		{
			DiskNumber       = 2
			RetryIntervalSec = $RetryIntervalSec
			RetryCount       = $RetryCount
		}

		cDiskNoRestart DataDisk                          # Prepare drive
        {
            DiskNumber = 2
            DriveLetter = "F"
        }

		WindowsFeature ADPS
		{
			Name   = "RSAT-AD-PowerShell"
			Ensure = "Present"
		}

		xComputer DomainJoin                              # Join the Domain
		{
			Name       = $env:COMPUTERNAME
			DomainName = $domain
			Credential = $DomainUserAccount
		}

		
		File FSWFolder
		{
			DestinationPath = "F:\$($SharePath.ToUpperInvariant())"
			Type            = "Directory"
			Ensure          = "Present"
			DependsOn       = "[xComputer]DomainJoin"
		}

		xSmbShare FSWShare
		{
			Name       = $SharePath.ToUpperInvariant()
			Path       = "F:\$($SharePath.ToUpperInvariant())"
			FullAccess = "BUILTIN\Administrators"
			Ensure     = "Present"
			DependsOn  = "[File]FSWFolder"
		}
	}
}


function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(        [string]$DomainName    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) { $length=15 }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) { return $DomainName.Substring(0,15) }
        else                           { return $DomainName                 }
    }
}