param ( $domain, $password )

# for this demo, we will use the classic Contoso for domain and
#                            ... demoUser and P@ssw0rd1234 for username and password


$smPassword = (ConvertTo-SecureString $password -AsPlainText -Force)

Install-WindowsFeature -Name "AD-Domain-Services" -IncludeAllSubFeature
Install-ADDSForest -DomainName $domain -DomainMode Win2012 -ForestMode Win2012 -Force -SafeModeAdministratorPassword $smPassword