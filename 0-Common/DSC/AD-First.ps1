configuration DemoAD1
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount
    )
		
    Import-DscResource -ModuleName xActiveDirectory
	

	Node localhost
	{
		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
			DebugMode = "ForceModuleImport"
		}

		Log Msg1
		{
			Message=$LocalUserAccount
		}

		Log Msg1
		{
			Message=$DomainUserAccount
		}

		WindowsFeature ADDSInstall
		{
			Ensure = "Present"
			Name = "AD-Domain-Services"
			IncludeAllSubFeature = $true
		}

		xADDomain FirstDS
		{
			DomainName                    = $domain
			DomainAdministratorCredential = $LocalUserAccount
			SafemodeAdministratorPassword = $LocalUserAccount
    		DependsOn                     = "[WindowsFeature]ADDSInstall"
		}

		xWaitForADDomain DscForestWait
		{
		    DomainName           = $domain
		    DomainUserCredential = $DomainUserAccount
		    RetryCount           = 20
		    RetryIntervalSec     = 30
		    DependsOn            = "[xADDomain]FirstDS"
		}
	}
}

