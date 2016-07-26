Configuration DemoAllComponents
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
	Import-DscResource -Module xDatabase
	Import-DscResource -Module xSQL

    Node 'localhost'
    { 
		$webzip1 = "FabrikamFiber.Web.zip"
		$webzip2 = "FabrikamFiber.API.zip"
		$bacpac  = "FabrikamFiber.bacpac"

		$node = "node-v4.4.7-x64.msi"
		$iisnode = "iisnode-full-iis7-v0.2.2-x64.msi"
		$urlrewrite = "rewrite_amd64.msi"

		$stagingFolder  = "C:\Packages"
		$wwwrootFolder  = "C:\inetpub\wwwroot"

		$wwwrootFolder1 = $wwwrootFolder + '\' + $webzip1.TrimEnd('.zip')
		$wwwrootFolder2 = $wwwrootFolder + '\' + $webzip2.TrimEnd('.zip')

		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
		}
		

		xRemoteFile NodeEngineInstaller                    # Download the core Node engine
		{
			URI 		    = $SampleAppLocation + '\' + $node
			DestinationPath	=     $stagingFolder + '\' + $node
		}

		xRemoteFile IISNodeInstaller                       # Download IISNode component
		{
			URI 		    = $SampleAppLocation + '\' + $iisnode
			DestinationPath	=     $stagingFolder + '\' + $iisnode
		}

		xRemoteFile URLReWriteInstaller                   # Download rewerite
		{
			URI 		    = $SampleAppLocation + '\' + $urlrewrite
			DestinationPath	=     $stagingFolder + '\' + $urlrewrite
		}

		xRemoteFile WebContent1                            # Download presentation layer of Sample App
		{  
			URI             = $SampleAppLocation + '\' + $webzip1
			DestinationPath =     $stagingFolder + '\' + $webzip1
		}         

		xRemoteFile WebContent2                            # Download middle tier of Sample App
		{  
			URI             = $SampleAppLocation + '\' + $webzip2
			DestinationPath =     $stagingFolder + '\' + $webzip2
		}         

		xRemoteFile GetBacpac                              # Download bacpac of database for SampleApp
		{  
			URI             = $SampleAppLocation + '\' + $bacpac
			DestinationPath =     $stagingFolder + '\' + $bacpac
		}         



		Package NodeEngineInstaller                        # Install the core Node engine
		{
			Ensure     = "Present"
			Name       = "Node.js"
			ProductId  = "8434AEA1-1294-47E3-9137-848F546CD824"
			Path       = $stagingFolder + '\' + $node
			Arguments  = "/passive"
			ReturnCode = 0
			DependsOn  = "[xRemoteFile]NodeEngineInstaller"
			LogPath    = $stagingFolder + "\install-1.log"
		}

		Package IISNodeInstaller                           # Install IISNode component
		{
			Ensure     = "Present"
			Name       = "iisnode for iis 7.x (x64) full"
			ProductId  = "18A31917-64A9-4998-AD54-56CCAEDC0DAB"
#			Name       = "iisnode for iis 7.x (x64) full"
#			ProductId  = "6C6CF372-FF11-4E05-B343-6586B3BC41E2"
			Path       = $stagingFolder + '\' + $iisnode
			Arguments  = "/passive"
			ReturnCode = 0
			DependsOn  = @("[xRemoteFile]IISNodeInstaller","[WindowsFeature]IIS")
			LogPath    = $stagingFolder + "\install-2.log"
		}

		Package URLReWriteInstaller                        # Install rewerite
		{
			Ensure     = 'Present'
			Name       = 'IIS URL Rewrite Module 2'
			ProductId  = "08F0318A-D113-4CF0-993E-50F191D397AD"
			Path       = $stagingFolder + '\' + $urlrewrite
			Arguments  = "/passive"
			ReturnCode = 0
			DependsOn  = @("[xRemoteFile]URLReWriteInstaller","[WindowsFeature]IIS")
			LogPath    = $stagingFolder + "\install-3.log"
		}



	




		Archive WebContent1                                # Unzip presentatin layer
		{  
			Ensure      = "Present"
			Path        =  $stagingFolder  + '\' + $webzip1
			Destination = "$wwwrootFolder" + '\' + $webzip1.TrimEnd('.zip')
			DependsOn   = "[xRemoteFile]WebContent1"
		}         

		Archive WebContent2                                # Unzip middle tier
		{  
			Ensure      = "Present"
			Path        = $stagingFolder   + '\' + $webzip2
			Destination = "$wwwrootFolder" 
			DependsOn   = "[xRemoteFile]WebContent2"
		}         
		



		xDatabase LoadDB                                   # Load bacpac, which also creates login for db user
		{
			Ensure           = "Present"
			SqlServer        = "localhost"
			SqlServerVersion = "2014"
			BacPacPath       = $stagingFolder + '\' + $bacpac
			DatabaseName     = 'FabrikamFiber'
			DependsOn        = "[xRemoteFile]GetBacpac"
		} 

		xDatabaseServer SetMixedMode                       # We need mixed auto mode on SQL
		{
			LoginMode        = "Mixed"
		}  



		xDatabaseLogin AppCred                             # We need to set the password for the login (bacpac provides login but no password)
		{
			Ensure                  = "Present"
			LoginName               = "MSFTAzureARM"
			LoginPassword           = "rQ53uUn3rm"
			SQLAuthType             = "Windows"
			SQLServer               = "localhost"
			DependsOn               = "[xDatabase]LoadDB"
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

		xWebsite Fabrikam2
		{  
			Ensure          = "Present"
			Name            = "Sample Application2" 
			State           = "Started"
			PhysicalPath    = $wwwrootFolder + '\' + $webzip2.TrimEnd('.zip')
			BindingInfo  = MSFT_xWebBindingInformation 
				{
					Protocol = 'HTTP'
					Port     = 3000
					HostName = '*'
				}
			DependsOn       = "[xWebsite]Fabrikam1"
		}  




	}
} 

