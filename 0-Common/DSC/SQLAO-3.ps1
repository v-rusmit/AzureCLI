Configuration DemoSQL
{
	param
	(
       	[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()]       [string] $domain,
                                                                      [string] $AppName,
										                              [string] $SampleAppLocation,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $LocalUserAccount,
		[Parameter(Mandatory=$true)] [ValidateNotNullorEmpty()] [PSCredential] $DomainUserAccount,
		

		[String[]]$Nodes            = @("my4appqasqlvm1.Fabrikam.com","my4appqasqlvm2.fabrikam.com"),
        [String]$DomainNetbiosName  = (Get-NetBIOSName -DomainName $domain),
        [UInt32]$DatabaseEnginePort = 1433,
		   [Int]$RetryCount         = 20,
           [Int]$RetryIntervalSec   = 30,

		[string]$LBName        = 'lb123',
		[string]$LBAddress     = '10.0.8.250',
		[string]$DNSServerName = 'my4appqaadvm0',
		[string]$DatabaseNames = 'FabrikamFiber'
    )
	
    [string]$LBFQName="${LBName}.${$domain}"

	Import-DscResource -Module xStorage
	Import-DscResource -Module cDisk
	Import-DscResource -Module xComputerManagement
	Import-DscResource -Module xActiveDirectory
	Import-DscResource -Module xNetworking
	Import-DscResource -Module xSQL
	Import-DscResource -Module xFailoverCluster

	$SQLServiceAccount = "PuppyDog"
	$ClusterName       = $DomainNetbiosName + 'Cluster'
	$SharePath         = '\\my4appqasqlvm0\' + $ClusterName
	$SqlAOEndpointName = $ClusterName + '-hadr'
	$SqlAOAvailGrpName = $ClusterName + '-ag'
	$SqlAOAvailGrpLstn = $ClusterName + '-ls'

    [System.Management.Automation.PSCredential]$SQLServiceCreds = New-Object System.Management.Automation.PSCredential ("${DomainNetbiosName}\$SQLServiceAccount", $DomainUserAccount.Password)
	
	
    Enable-CredSSPNTLM -DomainName $domain

	Node localhost
	{
		LocalConfigurationManager
		{
			RebootNodeIfNeeded = $true
		}

		xWaitforDisk Disk2                               # Make Sure Disk is Ready
		{
			DiskNumber       = 2
			RetryIntervalSec = $RetryIntervalSec
			RetryCount       = $RetryCount
		}

		cDiskNoRestart DataDisk                          # Prepare drive
        {
            DiskNumber = 2
            DriveLetter = "F"
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

		xComputer DomainJoin                              # Join the Domain
		{
			Name       = $env:COMPUTERNAME
			DomainName = $domain
			Credential = $DomainUserAccount
		}






        xFirewall DatabaseEngineFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Engine-TCP-In"
            DisplayName = "SQL Server Database Engine (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Engine."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = $DatabaseEnginePort -as [String]
            Ensure = "Present"
        }

        xFirewall DatabaseMirroringFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Database-Mirroring-TCP-In"
            DisplayName = "SQL Server Database Mirroring (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Database Mirroring."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = "5022"
            Ensure = "Present"
        }

        xFirewall ListenerFirewallRule
        {
            Direction = "Inbound"
            Name = "SQL-Server-Availability-Group-Listener-TCP-In"
            DisplayName = "SQL Server Availability Group Listener (TCP-In)"
            Description = "Inbound rule for SQL Server to allow TCP traffic for the Availability Group listener."
            DisplayGroup = "SQL Server"
            State = "Enabled"
            Access = "Allow"
            Protocol = "TCP"
            LocalPort = "59999"
            Ensure = "Present"
        }






        xSqlLogin AddSqlServerServiceAccountToSysadminServerRole           # we created a service account - make that an admin too
        {
            Name        = $SQLServiceCreds.UserName
            LoginType   = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled     = $true
            Credential  = $LocalUserAccount
            DependsOn   = "[xComputer]DomainJoin"
        }

        xSqlLogin AddDomainAdminAccountToSysadminServerRole              # make the domain admin (AzureAdmin) a sysadmin.  the local admin already is !
        {
            Name        = $DomainUserAccount.UserName
            LoginType   = "WindowsUser"
            ServerRoles = "sysadmin"
            Enabled     = $true
            Credential  = $LocalUserAccount
            DependsOn   = "[xComputer]DomainJoin"
        }


		xCluster FailoverCluster
        {
            Name                          = $ClusterName
            DomainAdministratorCredential = $DomainUserAccount
            Nodes                         = $Nodes
        }

		xClusterQuorum FailoverClusterQuorum
		{
			Name                          = $ClusterName
			DomainAdministratorCredential = $DomainUserAccount
			SharePath                     = $SharePath
		}
		
        xSqlServer ConfigureSqlServerWithAlwaysOn
        {
            InstanceName                  = $env:COMPUTERNAME
            SqlAdministratorCredential    = $DomainUserAccount
            ServiceCredential             = $SQLServiceCreds
            MaxDegreeOfParallelism        = 1
			Hadr                          = "Enabled"
            FilePath                      = "F:\DATA"
            LogPath                       = "F:\LOG"
            DomainAdministratorCredential = $DomainUserAccount
            DependsOn                     = "[xSqlLogin]AddDomainAdminAccountToSysadminServerRole"
        }

		xSqlEndpoint SqlAlwaysOnEndpoint
		{
			InstanceName                  = $env:COMPUTERNAME
			Name                          = $SqlAOEndpointName
			PortNumber                    = 5022
			AllowedUser                   = $SQLServiceCreds.UserName
			SqlAdministratorCredential    = $DomainUserAccount
			DependsOn                     = "[xSqlServer]ConfigureSqlServerWithAlwaysOn"
		}

		xSqlServer ConfigureSqlServerSecondaryWithAlwaysOn
		{
			InstanceName                  = $Nodes[0]
			SqlAdministratorCredential    = $DomainUserAccount
			Hadr                          = "Enabled"
			DomainAdministratorCredential = $DomainUserAccount
			DependsOn                     = "[xSqlEndPoint]SqlAlwaysOnEndpoint"
		}

		xSqlEndpoint SqlSecondaryAlwaysOnEndpoint
		{
			InstanceName               = $Nodes[0]
			Name                       = $SqlAOEndpointName
			PortNumber                 = 5022
			AllowedUser                = $SQLServiceCreds.UserName
			SqlAdministratorCredential = $DomainUserAccount
			DependsOn                  = "[xSqlServer]ConfigureSqlServerSecondaryWithAlwaysOn"
		}







		xSqlAvailabilityGroup SqlAG
		{
			Name                       = $SqlAOAvailGrpName
			ClusterName                = $ClusterName
			InstanceName               = $env:COMPUTERNAME
			PortNumber                 = 5022
			DomainCredential           = $DomainUserAccount
			SqlAdministratorCredential = $DomainUserAccount
			DependsOn                  = "[xSqlEndpoint]SqlSecondaryAlwaysOnEndpoint"
		}

		#xSQLAddListenerIPToDNS UpdateDNSServer
		#{
		#	Credential    = $DomainUserAccount
		#	LBName        = $LBName
		#	LBAddress     = $LBAddress
		#	DomainName    = $domain
		#	DNSServerName = $DNSServerName
		#}

		#xSqlAvailabilityGroupListener SqlAGListener
		#{
		#	Name                       = $SqlAOAvailGrpLstn
		#	AvailabilityGroupName      = $SqlAOAvailGrpName
		#	DomainNameFqdn             = $LBFQName
		#	LBAddress                  = $LBAddress
		#	ListenerPortNumber         = 1433
		#	ProbePortNumber            = 59999
		#	InstanceName               = $env:COMPUTERNAME
		#	DomainCredential           = $DomainUserAccount
		#	SqlAdministratorCredential = $DomainUserAccount
		#	DependsOn                  = @("[xSqlAvailabilityGroup]SqlAG","[xSQLAddListenerIPToDNS]UpdateDNSServer")
		#}

		xSqlNewAGDatabase SQLAGDatabases
		{
			SqlAlwaysOnAvailabilityGroupName = $SqlAOAvailGrpName
			DatabaseNames                    = $DatabaseNames
			PrimaryReplica                   = $Nodes[0]
			SecondaryReplica                 = $Nodes[1]
			SqlAdministratorCredential       = $DomainUserAccount
#			DependsOn                        = "[xSqlAvailabilityGroupListener]SqlAGListener"
		}

		#xSqlTestAGDatabase SQLAGDatabasesVerification
		#{
		#	SqlAlwaysOnAvailabilityGroupName = $SqlAOAvailGrpName
		#	InstanceName                     = $env:COMPUTERNAME
		#	DomainCredential                 = $DomainUserAccount
		#	DependsOn                        = "[xSqlNewAGDatabase]SQLAGDatabases"
		#}


	}
}


function Get-NetBIOSName
{ 
    [OutputType([string])]
    param(        [string]$DomainName    )

    if ($DomainName.Contains('.')) {
        $length=$DomainName.IndexOf('.')
        if ( $length -ge 16) { $length=15 }
        return $DomainName.Substring(0,$length)
    }
    else {
        if ($DomainName.Length -gt 15) { return $DomainName.Substring(0,15) }
        else                           { return $DomainName                 }
    }
}

 
function Enable-CredSSPNTLM
{
    param(
        [Parameter(Mandatory=$true)]
        [string]$DomainName
    )

    # This is needed for the case where NTLM authentication is used

    Write-Verbose 'STARTED:Setting up CredSSP for NTLM'

    Enable-WSManCredSSP -Role client -DelegateComputer localhost, *.$DomainName -Force -ErrorAction SilentlyContinue
    Enable-WSManCredSSP -Role server -Force -ErrorAction SilentlyContinue

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows -Name '\CredentialsDelegation' -ErrorAction SilentlyContinue
    }

    if( -not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'ConcatenateDefaults_AllowFreshNTLMOnly' -value '1' -PropertyType dword -ErrorAction SilentlyContinue
    }

    if(-not (Test-Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -ErrorAction SilentlyContinue))
    {
        New-Item -Path HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation -Name 'AllowFreshCredentialsWhenNTLMOnly' -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '1' -value "wsman/$env:COMPUTERNAME" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '2' -value "wsman/localhost" -PropertyType string -ErrorAction SilentlyContinue
    }

    if (-not (Get-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -ErrorAction SilentlyContinue))
    {
        New-ItemProperty HKLM:\SOFTWARE\Policies\Microsoft\Windows\CredentialsDelegation\AllowFreshCredentialsWhenNTLMOnly -Name '3' -value "wsman/*.$DomainName" -PropertyType string -ErrorAction SilentlyContinue
    }

    Write-Verbose "DONE:Setting up CredSSP for NTLM"
}


