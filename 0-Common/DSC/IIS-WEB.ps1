Configuration DemoIIS
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
                                                                      [string] $SampleAppLocation,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount
    )
	
	Import-DscResource -Module xPSDesiredStateConfiguration
	Import-DscResource -Module xWebAdministration

    Node 'localhost'
    { 
		$webzip1 = "FabrikamFiber.Web.zip"

		$stagingFolder  = "C:\Packages"
		$wwwrootFolder  = "C:\inetpub\wwwroot"

		$wwwrootFolder1 = $wwwrootFolder + '\' + $webzip1.TrimEnd('.zip')

		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
		}
		


		xRemoteFile WebContent1
		{  
			URI             = $SampleAppLocation + '\' + $webzip1
			DestinationPath =     $stagingFolder + '\' + $webzip1
		}         

		Archive WebContent1
		{  
			Ensure      = "Present"
			Path        = $stagingFolder + '\' + $webzip1
			Destination = "$wwwrootFolder"
			DependsOn   = "[xRemoteFile]WebContent1"
		}         



		xWebsite DisableDefaultSite
		{  
			Ensure          = "Present"
			Name            = "Default Web Site"
			State           = "Stopped"
			PhysicalPath    = $wwwrootFolder
			DependsOn       = "[WindowsFeature]IIS"
		}  

		xWebsite Fabrikam1
		{  
			Ensure          = "Present"
			Name            = "Sample Application" 
			State           = "Started"
			PhysicalPath    =  $wwwrootFolder + '\' + $webzip1.TrimEnd('.zip')
			DependsOn       = "[Archive]WebContent1"
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
} 
