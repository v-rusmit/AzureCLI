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


} 
