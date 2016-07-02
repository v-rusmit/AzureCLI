Configuration DemoIIS
{
	param
	(
        [string[]]     $AppName,
		[PSCredential] $UserAccount
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