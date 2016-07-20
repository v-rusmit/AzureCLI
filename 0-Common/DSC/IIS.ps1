Configuration DemoIIS
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount
    )

    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $true
    }

    WindowsFeature IIS
    {
        Ensure = "Present"
        Name = "Web-Server"
    }

    WindowsFeature ASP
    {
        Ensure = "Present"
        Name = "Web-Asp-Net45"
    }

    WindowsFeature WebMgmtConsole
    {
        Ensure = "Present"
        Name = "Web-Mgmt-Console"
    }

} 