Configuration DemoIIS
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount
    )
	
	Import-DscResource -Module xWebAdministration
	Import-DscResource -Module xPSDesiredStateConfiguration

#	$webzip1 = "FabrikamFiber.Web.zip"
	$webzip2 = "FabrikamFiber.API.zip"
#	$bacpac  = "FabrikamFiber.bacpac"

	$stagingFolder  = "C:\Packages"
	$wwwrootFolder  = "C:\inetpub\wwwroot"
	$storacct = "https://clijson.blob.core.windows.net/common-stageartifacts/"

#	$wwwrootFolder1 = $wwwrootFolder + '\' + $webzip1.TrimEnd('.zip')
	$wwwrootFolder2 = $wwwrootFolder + '\' + $webzip2.TrimEnd('.zip')

    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

	xRemoteFile WebContent2
	{  
		URI             = $storacct + $webzip2
		DestinationPath = $stagingFolder + '\' + $webzip2
	} 
	
	Archive WebContent2
	{  
		Ensure      = "Present"
		Path        = $stagingFolder + '\' + $webzip2
		Destination = "$wwwrootFolder"
		DependsOn   = "[xRemoteFile]WebContent2"
	}         

	xWebsite DisableDefaultSite
	{  
		Ensure          = "Present"
		Name            = "Default Web Site"
		State           = "Stopped"
		PhysicalPath    = $wwwrootFolder
		DependsOn       = "[WindowsFeature]IIS"
	}  

	xWebsite Fabrikam2
	{  
		Ensure          = "Present"
		Name            = "Sample Application2" 
		State           = "Started"
		PhysicalPath    = $wwwrootFolder + '\' + $webzip2.TrimEnd('.zip')
		BindingInfo  = MSFT_xWebBindingInformation 
			{
				Protocol = 'HTTP'
				Port     = 7777
				HostName = '*'
			}
		DependsOn       = "[xWebsite]DisableDefaultSite"
	}  





    WindowsFeature IIS
    {
        Name   = "Web-Server"
        Ensure = "Present"
    }

	WindowsFeature IISCommon
	{  
		Name                 = "Web-Common-Http"
		Ensure               = "Present"
		IncludeAllSubFeature = $true
 		DependsOn            = "[WindowsFeature]IIS"
	}  

	WindowsFeature URLAuth
	{  
		Name      = "Web-Url-Auth"
		Ensure    = "Present"
		DependsOn = "[WindowsFeature]IIS"
	}  

	WindowsFeature WindowsAuth
	{  
		Name      = "Web-Windows-Auth"
		Ensure    = "Present"
		DependsOn = "[WindowsFeature]IIS"
	}  

	WindowsFeature AspNet35
	{  
		Name      = "Web-Asp-Net"
		Ensure    = "Present"
		DependsOn = "[WindowsFeature]IIS"
	}  

	WindowsFeature AspNet45
	{  
		Name      = "Web-Asp-Net45"
		Ensure    = "Present"
		DependsOn = "[WindowsFeature]IIS"
	}  

	WindowsFeature Core
	{  
		Name      = "Web-WHC"
		Ensure    = "Present"
		DependsOn = "[WindowsFeature]IIS"
	}  

	WindowsFeature IISMgmtTools
	{  
		Name                 = "Web-Mgmt-Tools"
		Ensure               = "Present"
		IncludeAllSubFeature = $true
		DependsOn            = "[WindowsFeature]IIS"
	}  

} 