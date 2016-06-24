param ( $domain, $username, $password )

# for this demo, we will use the classic Contoso for domain and
#                            ... demoUser and P@ssw0rd1234 for username and password

$smPassword = (ConvertTo-SecureString $password -AsPlainText -Force)
$username   = "$domain\$username" 
$credential = New-Object System.Management.Automation.PSCredential($username, $smpassword)

Install-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature
Add-Computer -DomainName $domain -Credential $credential

