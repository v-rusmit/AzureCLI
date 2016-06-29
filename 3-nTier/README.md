# Running VMs for an N-tier architecture on Azure

## Description
This configuration runs virtual machines (VMs) for an application with a N-tier architecture.
There are variations of N-tier architectures. A typical 3-tier web app is assumed here:
* Web tier. Handles incoming HTTP requests. Responses are returned through this tier.
* Business tier. Implements business processes and other functional logic for the system.
* Data tier. Provides persistent data storage.

 ![diagram](../images/nTierVM.png)

## Prescriptive Guidance
Prescriptive  guidance plus considerations for availability, manageability, and security is available [here](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-3-tier-vm/).

## Related Training
* [Azure Network Security Groups (NSGs)](https://azure.microsoft.com/en-us/documentation/articles/virtual-networks-nsg/)
* [Adding reliability to an N-tier architecture on Azure](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-n-tier-vm/)
* [Networking basics for building applications in Azure](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-single-vm/#architecture-diagram)
* [Microsoft Azure Fundamentals:  Configure an Availability Set](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-single-vm/#architecture-diagram)

## Tools
* [Installing the Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
* [Installing and configuring Azure Powershell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

## Deployment
* Sample solution
* PowerShell
* CLI

[![Deploy to Azure](../images/azurebtn.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-autopatching%2Fazuredeploy.json)
