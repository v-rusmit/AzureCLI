param ( $domain, $username, $password )

$smPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
$username   = "$domain\$username" 
$credential = New-Object System.Management.Automation.PSCredential($username, $smpassword)

#Install-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature
Add-Computer -DomainName $domain -Credential $credential 

