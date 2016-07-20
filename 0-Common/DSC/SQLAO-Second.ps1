Configuration DemoSQL
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
                                                                      [string] $SampleAppLocation,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount,
		
        [Int]$RetryCount      =20,
        [Int]$RetryIntervalSec=30
    )

	
	Import-DscResource -Module xStorage
	Import-DscResource -Module xComputerManagement
	Import-DscResource -Module xNetworking
	Import-DscResource -Module xActiveDirectory
	Import-DscResource -Module xSQL
#	Import-DscResource -Module xPSDesiredStateConfiguration
#	Import-DscResource -Module xDatabase
#	Import-DscResource -Module xFailoverCluster

	
	$bacpac = "FabrikamFiber.bacpac"
	$stagingFolder  = "C:\Packages"

	Node localhost
	{
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
			Name   = "RSAT-Clustering"
			Ensure = "Present"
			IncludeAllSubFeature = $true
		}

		WindowsFeature ADPS
		{
			Name   = "RSAT-AD-PowerShell"
			Ensure = "Present"
		}

		xComputer DomainJoin
		{
			Name       = $env:COMPUTERNAME
			DomainName = $domain
			Credential = $DomainUserAccount
		}

		#xCluster FailoverCluster
		#{
		#	Name                          = "ClusterABC"
		#	StaticIPAddress               = "10.0.8.250"
		#	DomainAdministratorCredential = $DomainUserAccount
		#	DependsOn                     = "[xComputer]DomainJoin"

		#}
	}
} 