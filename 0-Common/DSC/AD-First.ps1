configuration DemoAD1
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
                                                                      [string] $SampleAppLocation,
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

		WindowsFeature ADDSInstall
		{
			Ensure = "Present"
			Name = "AD-Domain-Services"
			IncludeAllSubFeature = $true
		}

		WindowsFeature ADTools
		{
			Ensure = "Present"
			Name = "RSAT-AD-Tools"
			IncludeAllSubFeature = $true
		}

		xADDomain FirstDS
		{
			DomainName                    = $domain
			DomainAdministratorCredential = $LocalUserAccount
			SafemodeAdministratorPassword = $LocalUserAccount
			DependsOn                     = "[WindowsFeature]ADDSInstall"
		}

	}
}
