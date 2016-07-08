# Virtual Data Center

## Overview
A set of proven practices for running a reliable N-tier architecture on Windows virtual machines (VMs) in Microsoft Azure. Builds on Running VMs for an N-tier architecture on Azure.   Additional components are included that can increase the reliability of the application:

* A network virtual appliance for greater network security.
* SQL Server AlwaysOn Availability Groups for high availability in the data tier

## Prescriptive Guidance
Prescriptive  guidance plus considerations for availability, manageability, and security is available [here](https://azure.microsoft.com/en-us/documentation/articles/guidance-hybrid-network-vpn/#troubleshooting).

 ![GitHub Logo](../images/hybridNetwork.png)
 
## Related Training
 * [Azure Network Security Groups (NSGs)](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/)
 * [Adding reliability to an N-tier architecture on Azure](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-n-tier-vm/)
 * [Networking basics for building applications in Azure](link needed)
 * [Microsoft Azure Fundamentals:  Configure an Availability Set](link needed)

## Tools
 * [Installing the Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
 * [Installing and configuring Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

## Deployment
* [PowerShell](./Scripts/Deploy-AzureResourceGroup.ps1)
* [CLI](./Scripts/CLIDeploy-VDC.bat)

[![Deploy to Azure](../images/azurebtn.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-autopatching%2Fazuredeploy.json)
