configuration DemoAD1
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $UserAccount
    )
		
    Import-DscResource -ModuleName xActiveDirectory
	

	Node localhost
	{
		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
			DebugMode = "ForceModuleImport"
		}

		WindowsFeature ADDSInstall
		{
			Ensure = "Present"
			Name = "AD-Domain-Services"
		}

		xADDomain FirstDS
		{
			DomainName                    = $domain
			DomainAdministratorCredential = $UserAccount
			SafemodeAdministratorPassword = $UserAccount
    		DependsOn                     = "[WindowsFeature]ADDSInstall"
		}

		xWaitForADDomain DscForestWait
		{
		    DomainName           = $domain
		    DomainUserCredential = $UserAccount
		    RetryCount           = 20
		    RetryIntervalSec     = 30
		    DependsOn            = "[xADDomain]FirstDS"
		}
	}
}

