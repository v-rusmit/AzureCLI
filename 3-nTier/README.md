# Running VMs for an N-tier architecture on Azure
*By Mike Wasson (https://github.com/MikeWasson)*

Updated: 06/06/2016

###### In this article:
* Architecture diagram
* Network recommendations
* Availability
* Security
* Scalability
* Manageability
* Example deployment script
* Next steps
* 0 Comments

## patterns & practices

proven practices for predictable results
(http://aka.ms/mspnp)

This article outlines a set of proven practices for running virtual machines (VMs) for an application with a N-tier architecture.

There are variations of N-tier architectures. For the most part, the differences shouldn't matter for the purposes of these recommendations. This article assumes a typical 3-tier web app:
* **Web tier.** Handles incoming HTTP requests. Responses are returned through this tier.
* **Business tier.** Implements business processes and other functional logic for the system.
* **Data tier.** Provides persistent data storage.

###### **Note:**
Azure has two different deployment models: Resource Manager (../resource-groupoverview/) and classic. This article uses Resource Manager, which Microsoft recommends for new deployments.

## Architecture diagram
The following diagram builds on the topology shown in Running multiple VMs on Azure (../guidance-compute-multi-vm/). 

 ![GitHub Logo](../images/nTierVM.png)

* **Availability Sets.** Create an Availability Set (../virtual-machines-windows-manageavailability/#configure-each-application-tier-into-separate-availability-sets) for each tier, and provision at least two VMs in each tier. This approach is required to reach the availability SLA (https://azure.microsoft.com/en-us/support/legal/sla/virtualmachines/v1_0/) for VMs.

* **Subnets.** Create a separate subnet for each tier. Specify the address range and subnet mask using CIDR (https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation.

* **Load balancers.** Use an Internet-facing load balancer (../load-balancer-internetoverview/) to distribute incoming Internet traffic to the web tier, and an internal load balancer (../load-balancer-internal-overview/) to distribute network traffic from the web tier to the business tier.

* **Jumpbox.** A _jumpbox_, also called a bastion host
(https://en.wikipedia.org/wiki/Bastion_host), is a VM on the network that administrators use to connect to the other VMs. The jumpbox has an NSG that allows remote desktop (RDP) only from whitelisted public IP addresses.

* **Monitoring.** Monitoring software sush as Nagios (https://www.nagios.org/), Zabbix (http://www.zabbix.com/), or Icinga (http://www.icinga.org/) can give you insight into response time, VM uptime, and the overall health of your system. Install the monitoring software on a VM that's placed in a separate management subnet.

* **NSGs.** Use network security groups (../virtual-networks-nsg/) (NSGs) to restrict network traffic within the VNet. For example, in the 3-tier architecture shown here, the data tier does not accept traffic from the web front end, only from the business tier and the management subnet.

* **Key Vault.** Use Azure Key Vault (https://azure.microsoft.com/services/key-vault.md) to manage encryption keys, for encrypting data at rest.

## Network recommendations
###### VNet / Subnets

* When you create the VNet, allocate enough address space for the subnets you will need.
Specify the address range and subnet mask using CIDR
(https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) notation. Use an address space that falls within the standard private IP address blocks
(https://en.wikipedia.org/wiki/Private_network#Private_IPv4_address_spaces), which are
10.0.0.0/8, 172.16.0.0/12, and 192.168.0.0/16.

* Don't pick an address range that overlaps with your on-premise network, in case you need to set up a gateway between the VNet and your on-premise network later. Once you create the VNet, you can't change the address range.

* Design subnets with functionality and security requirements in mind. All VMs within the same tier or role should go into the same subnet, which can be a security boundary. Specify the address space for the subnet in CIDR notation. For example, '10.0.0.0/24' creates a range of 256 IP addresses. (VMs can use 251 of these; five are reserved. For more information, see the Virtual Network FAQ (../virtual-networks-faq/).) Make sure the address ranges don't overlap across subnets.


## Load balancers

* The external load balancer distributes Internet traffic to the web tier. Create a public IP address for this load balancer. Example:
```javascript
azure network public-ip create --name pip1 --location westus --resourceCopy-group rg
azure network lb create --name lb1 --location --location westus --resource-group
azure network lb frontend-ip create --name lb1-frontend --lb-name lb1 --public
```
For more information, see Get started creating an Internet facing load balancer using Azure CLI (../load-balancer-get-started-internet-arm-cli/)

* The internal load balancer distributes network traffic from the web tier to the business tier. To give this load balancer a private IP address, create a frontend IP configuration and associate it with the subnet for the business tier. Example:
```javascript
    azure network lb create --name lb2 --location --location westus --resourceCopy -group
azure network lb frontend-ip create --name lb2-frontend --lb-name lb2 --subnet--subnet-vnet-name vnet1 --resource-group rg1
```
For more information, see Get started creating an internal load balancer using the Azure CLI (../load-balancer-get-started-ilb-arm-cli/).

## Jumpbox

* Use a small VM size for the jumpbox, such as Standard A1. T

* The jumpbox belongs to the same VNet as the other VMs, and connects to them through their private IP addresses.

* Place the jumpbox in a separate management subnet, and create a public IP address (../virtual-network-ip-addresses-overview-arm/) for the jumpbox.

* To secure the jumpbox, create an NSG and apply it to jumpbox subnet. Add an NSG rule that allows remote desktop (RDP) only from a whitelisted set of public IP addresses.

The NSG can be attached either to the subnet or to the jumpbox NIC. In this case, we recommend attaching it to the NIC, so RDP traffic is permitted only to the jumpbox, even if you add other VMs to the same subnet.

## Availability

* Put each tier or VM role into a separate availability set. Don't put VMs from different tiers into the same availability set.

* At the data tier, having multiple VMs does not automatically translate into a highly available database. For a relational database, you will typically need to use replication and failover to achieve high availability. The business tier will connect to a primary database, and if that VM goes down, the application fails over to a secondary database, either manually or automatically.

###### Note:
For SQL Server, we recommend using AlwaysOn Availability Groups
(https://msdn.microsoft.com/en-us/library/hh510230.aspx). For more information, see

## Security
* Encrypt data at rest. Use Azure Key Vault (https://azure.microsoft.com/services/keyvault.md) to manage the database encryption keys. Key Vault can store encryption keys in hardware security modules (HSMs). For more information, see Configure Azure Key Vault Integration for SQL Server on Azure VMs (../virtual-machines-windows-ps-sqlkeyvault/) It's also recommended to store application secrets, such as database connection strings, in Key Vault.

* Do not allow RDP access from the public Internet to the VMs that run the application workload. Instead, all RDP access to these VMs must come through the jumpbox. An administrator logs into the jumpbox, and then logs into the other VM from the jumpbox. The jumpbox allows RDP traffic from the Internet, but only from known, whitelisted IP addresses.

* Use NSG rules to restrict traffic between tiers. For example, in the 3-tier architecture shown above, the web tier does not communicate directly with the data tier. To enforce this, the data tier should block incoming traffic from the web tier subnet.


1. Create an NSG and associate it to the data tier subnet.

2. Add a rule that denies all inbound traffic from the VNet. (Use the VIRTUAL_NETWORK tag in the rule.)

3. Add a rule with a higher priority that allows inbound traffic from the business tier subnet. This rule overrides the previous rule, and allows the business tier to talk to the data tier.

4. Add a rule that allows inbound traffic from within the data tier subnet itself. This rule allows communication between VMs in the data tier, which is needed for database replication and failover.

5. Add a rule that allows RDP traffic from the jumpbox subnet. This rule lets administrators connect to the data tier from the jumpbox.

###### Note:
> An NSG has default rules
> (../best-practices-resource-manager-security/#networksecurity-groups)
> that allow any inbound traffic from within the VNet. These rules can't be deleted,
> but you can override them by creating higher-priority rules.

## Scalability
The load balancers distribute network traffic to the web and business tiers. Scale horizontally by adding new VM instances. Note that you can scale the web and business tiers independently, based on load. To reduce possible complications caused by the need to maintain client affinity, the VMs in the web tier should be stateless. The VMs hosting the business logic should also be stateless.

## Manageability
Simplify management of the entire system by using centralized administration tools such as Azure Automation (../automation-intro/), Microsoft Operations Management Suite
(https://www.microsoft.com/en-us/server-cloud/operations-managementsuite/overview.aspx), Chef (https://www.chef.io/solutions/azure/), or Puppet
(https://puppetlabs.com/blog/managing-azure-virtual-machines-puppet). These tools can consolidate diagnostic and health information captured from multiple VMs to provide an overall view of the system.

## Example deployment script

An example deployment script for this architecture is available on GitHub.
* Bash script (Linux) (https://github.com/mspnp/blueprints/blob/master/3tierlinux/3TierCLIScript.sh)

* Batch file (Windows) (https://github.com/mspnp/blueprints/blob/master/3tierwindows/3TierCLIScript.cmd)

### Next steps
* This article shows a basic N-tier architecture. For some additional considerations about reliability, see Adding reliability to an N-tier architecture on Azure (../guidance-computen-tier-vm/).
