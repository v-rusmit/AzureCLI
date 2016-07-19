Configuration DemoSQL
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount,
		
        [Int]$RetryCount      =20,
        [Int]$RetryIntervalSec=30
    )

	
	Import-DscResource -Module xStorage
	Import-DscResource -Module xPSDesiredStateConfiguration
	Import-DscResource -Module xDatabase
	Import-DscResource -Module xComputerManagement
	Import-DscResource -Module xFailoverCluster
	
	$bacpac = "FabrikamFiber.bacpac"
	$storacct = "https://clijson.blob.core.windows.net/common-stageartifacts/"
	$stagingFolder  = "C:\Packages"

    LocalConfigurationManager
    {
        RebootNodeIfNeeded = $false
    }

	xWaitforDisk Disk2
	{
		DiskNumber       = 2
		RetryIntervalSec = $RetryIntervalSec
		RetryCount       = $RetryCount
	}

	WindowsFeature FC
	{
		Name   = "Failover-Clustering"
		Ensure = "Present"
	}

	WindowsFeature FCPS
	{
		Name   = "RSAT-Clustering-PowerShell"
		Ensure = "Present"
	}

	WindowsFeature ADPS
	{
		Name   = "RSAT-AD-PowerShell"
		Ensure = "Present"
	}

	#xComputer DomainJoin
	#{
	#	Name       = $env:COMPUTERNAME
	#	DomainName = $domain
	#	Credential = $DomainUserAccount
	#	UnjoinCredential = $DomainUserAccount
	#}

	xCluster FailoverCluster
	{
		Name                          = "ClusterDuck"
		StaticIPAddress               = "10.0.8.250"
		DomainAdministratorCredential = $DomainUserAccount
	}


} 