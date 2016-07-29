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
	
	Import-DscResource -Module xWebAdministration
	Import-DscResource -Module xPSDesiredStateConfiguration
	Import-DscResource -Module xNetworking

	$webzip2 = "FabrikamFiber.API.Ntier.zip"

	$node = "node-v4.4.7-x64.msi"
	$iisnode = "iisnode-full-iis7-v0.2.2-x64.msi"
	$urlrewrite = "rewrite_amd64.msi"

	$stagingFolder  = "C:\Packages"
	$wwwrootFolder  = "C:\inetpub\wwwroot"

    #Node 'localhost'
    #{ 

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

		xRemoteFile WebContent2
		{  
			URI             = $SampleAppLocation + '\' + $webzip2
			DestinationPath =     $stagingFolder + '\' + $webzip2
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




		xFirewall BizTierFirewallRule                          # Biz Tier talks on port 3000 
		{
			Direction    = "Inbound"
			Name         = "SampleApp-In"
			DisplayName  = "Allow BizTier"
			Description  = "Inbound rule for SampleApplcaiton Biz Tier"
			DisplayGroup = "IIS"
			State        = "Enabled"
			Access       = "Allow"
			Protocol     = "TCP"
			LocalPort    = "3000"
			Ensure       = "Present"
		}
	



		Archive WebContent2                                    # Unpack the zip file underneath WWWroot
		{  
			Ensure      = "Present"
			Path        = $stagingFolder + '\' + $webzip2
			Destination = $wwwrootFolder + '\' + $webzip2.TrimEnd('.Ntier.zip')
			DependsOn   = "[xRemoteFile]WebContent2"
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


		xWebsite DisableDefaultSite                            # dont run the default site
		{  
			Ensure          = "Present"
			Name            = "Default Web Site"
			State           = "Stopped"
			PhysicalPath    = $wwwrootFolder
			DependsOn       = "[WindowsFeature]IIS"
		}  

		xWebsite Fabrikam2                                     # Configure the site
		{  
			Ensure          = "Present"
			Name            = "Sample Application2" 
			State           = "Started"
			PhysicalPath    = $wwwrootFolder + '\' + $webzip2.TrimEnd('.Ntier.zip')
			BindingInfo  = MSFT_xWebBindingInformation 
				{
					Protocol = 'HTTP'
					Port     = 3000
					HostName = '*'
				}
			DependsOn       = "[xWebsite]DisableDefaultSite"
		}  
	#}
} 
