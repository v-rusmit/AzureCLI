# Virtual Data Center

## Overview
A set of proven practices for running a reliable N-tier architecture on Windows virtual machines (VMs) in Microsoft Azure. Builds on Running VMs for an N-tier architecture on Azure.   Additional components are included that can increase the reliability of the application:

* A network virtual appliance for greater network security.
* SQL Server AlwaysOn Availability Groups for high availability in the data tier

## Prescriptive Guidance
Prescriptive  guidance plus considerations for availability, manageability, and security is available [here](https://azure.microsoft.com/en-us/documentation/articles/guidance-hybrid-network-vpn/#troubleshooting).

 ![GitHub Logo](../images/virtualDatacenter.png)
 
## Related Training
 * [Azure Network Security Groups (NSGs)](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/)
 * [Adding reliability to an N-tier architecture on Azure](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-n-tier-vm/)
 * [Networking basics for building applications in Azure](https://azure.microsoft.com/en-us/documentation/videos/azurecon-2015-networking-basics-for-building-applications-in-azure/)
 * [Microsoft Azure Fundamentals:  Configure an Availability Set](https://azure.microsoft.com/en-us/documentation/articles/virtual-machines-windows-create-availability-set/)

## Tools
 * [Installing the Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
 * [Installing and configuring Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

##Barracuda NVA

This template provisions two Network Virtual Appliance (NVAs) via 3rd party vendor Barracuda.  Be aware of the following addition charges provisioning this NVA (costs below reflect the costs for a single NVA):

Offer details  
1.3200 USD/hr  
Barracuda Web Application Firewall  
by Barracuda Networks, Inc.

Terms of use | [privacy policy](https://www.barracuda.com/legal/privacy)  
0.2500 USD/hr  
[Pricing for other VM sizes](http://azure.microsoft.com/pricing/details/virtual-machines/#Linux)  
Standard A5  
by Microsoft  
[Terms of use](http://azure.microsoft.com/support/legal/) | [privacy policy](https://www.microsoft.com/privacystatement/en-us/OnlineServices/Default.aspx)

**The highlighted Marketplace purchase(s) are not covered by your Azure credits, and will be billed separately.**  
You cannot use your Azure monetary commitment funds or subscription credits for these purchases. You will be billed separately for marketplace purchases.
If you have previously purchased a free trial offering, your free trial period will run 30 days from the date of your original purchase; all use thereafter will be billed at the standard rates listed above.

**Azure resource**  
You may use your Azure monetary commitment funds or subscription credits for these purchases. Prices presented are retail prices and may not reflect discounts associated with your subscription.
Terms of use
By clicking “Purchase”, I (a) agree to the legal terms and privacy statement(s) associated with each Marketplace offering above, (b) authorize Microsoft to charge or bill my current payment method for the fees associated with my use of the offering(s), including applicable taxes, with the same billing frequency as my Azure subscription, until I discontinue use of the offering(s), and (c) agree that Microsoft may share my contact information and transaction details with the seller(s) of the offering(s). Microsoft does not provide rights for third-party products or services. See the [Azure Marketplace Terms](http://azure.microsoft.com/support/legal/marketplace-terms/) for additional terms.


## Deployment

### Deploy using the Azure Portal
[![Deploy to Azure](../images/azurebtn.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FValoremConsulting%2FAzureCLI%2Fmaster%2F4-VirtualDatacenter%2FTemplates%2Fazuredeploy.json%3Ftoken%3DASzQZuP3-DAqLbWH9XQZ64ng__0vAMT_ks5XkSL8wA%253D%253D)

You will need to be logged into the Azure portal under the subscription you would like to use.

### PowerShell
```PowerShell
New-AzureRmResourceGroupDeployment -Name <deployment-name> -ResourceGroupName <resource-group-name> -TemplateUri <template-uri>
```
[Install and configure Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

### CLI
```
azure config mode arm
azure group deployment create <my-resource-group> <my-deployment-name> --template-uri <template-uri>
```
[Install and Configure the Azure Cross-Platform Command-Line Interface](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)

