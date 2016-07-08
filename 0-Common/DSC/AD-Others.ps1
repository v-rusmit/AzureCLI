configuration DemoAD2
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
		}

		WindowsFeature ADDSInstall
		{
			Ensure = "Present"
			Name = "AD-Domain-Services"
			IncludeAllSubFeature = $true
		}

		xADDomainController SecondDC
		{
			DomainName                    = $domain.TrimEnd('.com')
			DomainAdministratorCredential = $DomainUserAccount
			SafemodeAdministratorPassword = $DomainUserAccount
			DependsOn                     = "[WindowsFeature]ADDSInstall"
		}
    }
}

