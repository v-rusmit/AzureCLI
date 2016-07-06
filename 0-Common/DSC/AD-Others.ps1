configuration DemoAD2
{
	param
	(
        [string[]]     $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $UserAccount
    )

	$domain = 'Fabrikam.com'

	$secpasswd = ConvertTo-SecureString "Sw!mmingP00l"  -AsPlainText -Force
	$domainCred =                New-Object System.Management.Automation.PSCredential ("Fabrikam\Administrator", $secpasswd)
	$safemodeAdministratorCred = New-Object System.Management.Automation.PSCredential ("Fabrikam\Administrator", $secpasswd)

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
		}

		xWaitForADDomain DscForestWait
		{
			DomainName = $domain
			DomainUserCredential = $domaincred
			RetryCount = 20
			RetryIntervalSec = 30
			DependsOn = "[WindowsFeature]ADDSInstall"
		}

		xADDomainController SecondDC
		{
			DomainName = $domain
			DomainAdministratorCredential = $domaincred
			SafemodeAdministratorPassword = $safemodeAdministratorCred
			DependsOn = "[xWaitForADDomain]DscForestWait"
		}
    }
}

