----------------
# Running a Windows VM on Azure

## Description

This configuration runs a single Windows virtual machine (VM) on Azure.  
Using a single VM for production workloads is not recommended, because there is no up-time SLA for single VMs on Azure.  To get the SLA, multiple VMs must be deployed in an availability set ([see Running multiple Windows VMs on Azure](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-multi-vm/))

## Prescriptive Guidance
Prescriptive  guidance plus considerations for availability, manageability, and security is available [here](https://azure.microsoft.com/en-us/documentation/articles/guidance-compute-single-vm/).

## Architecture diagram
 ![GitHub Logo](../images/singleVM.png)

## Related Training
* [Networking basics for building applications in Azure](http://github.com/)
* [Microsoft Azure Fundamentals: Configure an Availability Set](http://github.com/)

## Tools
* [Installing the Azure CLI](https://azure.microsoft.com/en-us/documentation/articles/xplat-cli-install/)
* [Installing and configuring Azure PowerShell](https://azure.microsoft.com/en-us/documentation/articles/powershell-install-configure/)

## Deployment
* Sample Solution
* PowerShell
* CLI

[![Deploy to Azure](../images/azurebtn.png)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Fazure-quickstart-templates%2Fmaster%2F201-vm-sql-full-autopatching%2Fazuredeploy.json)
