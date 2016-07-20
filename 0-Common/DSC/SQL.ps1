Configuration DemoSQL
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
	Import-DscResource -Module xDatabase
	
	$bacpac = "FabrikamFiber.bacpac"
	$stagingFolder  = "C:\Packages"

    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $false
    }

	xRemoteFile GetBacpac
	{  
		URI             = $SampleAppLocation + '\' + $bacpac
		DestinationPath =     $stagingFolder + '\' + $bacpac
	}         

	xDatabaseLogin AppCredw4DB
	{
		Ensure           = "Present"
		LoginName        = "sqlbat"
		LoginPassword    = "Sw!mmingP00l"
		SqlAuthType      = 'Windows'
		SqlServer        = "localhost"
	} 

	xDatabase LoadDB
	{
		Ensure           = "Present"
		SqlServer        = "localhost"
		SqlServerVersion = "2014"
		BacPacPath       = $stagingFolder + '\' + $bacpac
		DatabaseName     = 'FabrikamFiber'
		DependsOn        = "[xRemoteFile]GetBacpac"
	} 
} 
