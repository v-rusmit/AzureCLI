# Running multiple VMs on Azure for scalability and availability

*By Mike Wasson (https://github.com/MikeWasson) Updated: 06/06/2016*

###### In this article:
* Architecture diagram
* Scalability considerations
* Availability considerations
* Manageability considerations
* Security considerations
* Example deployment script
* Next steps
* 1 Comment

## Patterns & Practices
proven practices for predictable results (http://aka.ms/mspnp)

This article outlines a set of proven practices for running multiple virtual
machine (VM) instances, to improve availability and scalability. In this
architecture, the workload is distributed across the VM instances. There is a
single public IP address, and Internet traffic is distributed to the VMs using a
load balancer. This architecture can be used for a single-tier app, such as a
stateless web app or storage cluster. It is also a building block for N-tier
applications. This article builds on Running a Single VM on Azure
(../guidance-compute-single-vm/). The recommendations in that article also apply
to this architecture.

###### Note:
> Azure has two different deployment models: Resource Manager
> (../resource-groupoverview/) and classic. This article uses Resource Manager,
> which Microsoft recommends for new deployments.

## Architecture diagram

![GitHub Logo](../images/multiVM.png)

###### The architecture has the following components:
* **Availability Set.** Put the VMs into an Availability Set
(../virtual-machines-windowsmanage-availability/). This makes the VMs eligible
for the SLA (https://azure.microsoft.com/en-us/support/legal/sla/virtual-machines/v1_0/)
for virtual machines. For the SLA to apply, you need a minimum of two VMs in the
same availability set.

* **VNet.** Every VM in Azure is deployed into a virtual network (VNet), which
is further divided into subnets. For this scenario, place the VMs on the
same subnet.

* **Azure Load Balancer.** Use an Internet-facing load balancer
(../load-balancer-get-startedinternet-arm-cli/) to distribute incoming Internet
requests to the VM instances. The load balancer includes some related resources:

* **Public IP address.** A public IP address is needed for the load balancer to
receive Internet traffic.

* **Front-end configuration.** Associates the public IP address with the load balancer.

* **Back-end address pool.** Contains the network interfaces (NICs) for the VMs that
will receive the incoming traffic.

* **Load balancer rules** are used to distribute network traffic among all the VMs in
the back-end address pool. For example, to enable HTTP traffic, create a rule
that maps port 80 from the front-end configuration to port 80 on the back-end
address pool. When the load balancer receives a request on port 80 of the public IP
address, it will route the request to port 80 on one of the NICs in the
back-end address pool.

* **NAT rules** are used to route traffic to a specific VM. For example, to enable remote
desktop (RDP) to the VMs, create a separate NAT rule for each VM. Each rule should
map a distinct port number to port 3389, which is the default port for RDP. (For
example, use port 50001 for "VM1", port 50002 for "VM2", and so on.) Assign the NAT
rules to the NICs on the VMs.

* **Network interfaces (NICs).** Provision a NIC for each VM. The NIC provides network
connectivity to the VM. Associate the NIC with the subnet and also with the back-end
address pool of the load balancer.

* **Storage.** Create separate Azure storage accounts for each VM to hold the VHDs,
in order to avoid hitting the IOPS limits
(../azure-subscription-service-limits/#virtual-machinedisk-limits)
for storage accounts. Create one storage account for diagnostic logs. That account
can be shared by all the VMs.

## Scalability considerations

The load balancer takes incoming network requests and distributes them across the NICs
in the back-end address pool. To scale horizontally, add more VM instances to the
Availability Set (or deallocate VMs to scale down).

For example, suppose you're running a web server. You would add a load balancer rule for
port 80 and/or port 443 (for SSL). When a client sends an HTTP request, the load balancer
picks a back-end IP address by using a hashing algorithm (../load-balanceroverview/#
hash-based-distribution) that includes the source IP address. In that way, client
requests are distributed across all the VMs.

###### Tip:
> When you add a new VM to an Availability Set, make sure to create a NIC for the VM,
> and add the NIC to the back-end address pool on the load balancer. Otherwise,
> Internet traffic won't be routed to the new VM.

Each Azure Subscription has default limits in place, including a maximum number of VMs
per region. You can increase the limit by filing a support request. For more information,
see Azure subscription and service limits, quotas, and constraints (../azure-subscriptionservice-
limits/).

## Availability considerations

The Availability Set makes your app more resilient to both planned and unplanned
maintenance events.

* *Planned maintenance occurs* when Microsoft updates the underlying platform.
Sometimes, that causes VMs to be restarted. Azure makes sure the VMs in an Availability
Set are not restarted all at the same time, so at least one is kept running while others are
restarting.

* *Unplanned maintenance happens* if there is a hardware failure. Azure makes sure that
VMs within an Availability Set are provisioned across more than one server rack. This
helps to reduce the impact of hardware failures, network outages, power interruptions,
and so on.
For more information, see Manage the availability of virtual machines (../virtual-machineswindows-
manage-availability/). The following video also has a good overview of
Availability Sets: How Do I Configure an Availability Set to Scale VMs
(https://channel9.msdn.com/Series/Microsoft-Azure-Fundamentals-Virtual-Machines/08).

###### Warning:
> Make sure to configure the Availability Set when you provision the VM.
> Currently, there is no way to add a Resource Manager VM to an Availability Set
> after the VM is provisioned.

The load balancer uses health probes (../load-balancer-overview/#service-monitoring)
to monitor the availability of VM instances. If a probe cannot reach an instance
within a timeout period, the load balancer stops sending traffic to that VM.
However, the load balancer will continue to probe, and if the VM becomes available
again, the load balancer resumes sending traffic to that VM.

Here are some recommendations on load balancer health probes:

* Probes can test either HTTP or TCP. If your VMs run an HTTP server (IIS, nginx, Node.js
app, etc), create an HTTP probe. Otherwise create a TCP probe.

* For an HTTP probe, specify the path to the HTTP endpoint. The probe checks for an
HTTP 200 response from this path. Use a path that best represents the health of the VM
instance. This can be the root path ("/"), or you might implement a specific healthmonitoring
endpoint that has some custom logic. The endpoint must allow anonymous
HTTP requests.

* The probe is sent from a known (../virtual-networks-nsg/#special-rules) IP address,
168.63.129.16. Make sure you don't block traffic to or from this IP in any firewall policies
or network security group (NSG) rules.

* Use health probe logs (../load-balancer-monitor-log/) to view the status of the health
probes. Enable logging in the Azure portal for each load balancer. Logs are written to
Azure blob storage. The logs show how many VMs on the back-end are not receiving
network traffic due to failed probe responses.

## Manageability considerations

With multiple VMs, it becomes important to automate processes, so they are reliable and
repeatable. You can use Azure Automation (https://azure.microsoft.com/enus/
documentation/services/automation/) to automate deployment, OS patching, and other
tasks. Azure Automation is an automation service that runs on Azure, and is based on
Windows PowerShell. Example automation scripts are available at the Runbook Gallery
(../automation-runbook-gallery/#runbooks-in-runbook-gallery) on TechNet.

## Security considerations

Virtual networks are a traffic isolation boundary in Azure. VMs in one VNet cannot
communicate directly to VMs in a different VNet. VMs within the same VNet can
communicate, unless you create network security groups (../virtual-networks-nsg/) (NSGs)
to restrict traffic. For more information, see Microsoft cloud services and network security
(../best-practices-network-security/).

For incoming Internet traffic, the load balancer rules define which traffic can reach the back
end. However, load balancer rules don't support IP whitelisting, so if you want to whitelist
certain public IP addresses, add an NSG to the subnet.

## Example deployment script

An example deployment script for this architecture is available on GitHub.
* Bash script (Linux) (https://github.com/mspnp/blueprints/blob/master/multivmlinux/
azurecli-multi-vm-single-tier-sample.sh)
* Batch file (Windows) (https://github.com/mspnp/blueprints/blob/master/multivmwindows/
azurecli-multi-vm-single-tier-sample.cmd)
The script requires version 0.9.20 or later of the Azure Command-Line Interface (CLI)
(../virtual-machines-command-line-tools/).

## Next steps

* Putting several VMs behind a load balancer is a building block for creating multi-tier
architectures. For more information, see Running VMs for an N-tier architecture on
Azure (../guidance-compute-3-tier-vm/).
