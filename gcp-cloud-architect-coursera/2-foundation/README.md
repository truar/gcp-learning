# Week 2 - Foundation

## GCP

Cloud shell offers 5Gb of persistent storage to the users, with pre install cloud SDK

## Projects
Shutdown project are scheduled to be deleted after 30 days when the user asks for

4 ways to interact with GCP :
* GCP Console
* Cloud shell
* Cloud SDK
* Mobile app


## VPC 

* Automatic network: Creates all the subnetworks automatically, one by region, even when google starts a new Region
    * Non overlapping IP Addresses range
        * Default range is /20, can be extended to /16 if needed
    * Default preset: 
        * Allow ingress traffic for ICMP, SSH and RDP only
        * Allow every *internal* communication on every port
    
* Custom network: You have to choose what subnets you want to create.
    * Complete control, and specify bigger range
    
* Subnets migration:
    * Auto -> Custom : possible
    * Custom -> auto : Not possible

Every project comes with a `default` network:
* Is automatic, therefor, has preset subnets
* Comes with a preset of firewall rules

Network isolation :
* A & B can communicate over internal IP in the same network, even in different regions (i.e different subnets)
* C & D must communicate over external IPs addresses, if they are in different network, even if it is the same region.
    * traffic is not going over the internet, but pass over the Google edge routers
    
Use VPN to communicate with your VMs if needed, can reduce costs.

Subnet:
* has 4 reserved IP addresses in its primary range
* A single firewall rule can be applied to both VM

Increase IP address space without downtime

* No overlap
* Subnet can be of different size
* RFC 1918 address spaces
* You can't undo an expansion
* Avoid large subnet
* Do not scale subnet beyond what we actually need

If the subnet does not have any IP Addresses left, you can't create compute engine. You must expand your subnet (go in the subnet edit panel in GCP)

Every VM has 2 IP:
* Internal
    * Allocated from subnet range
    * DHCP lease is renewed every 24hours
    * VM name + IP is registered with network scope DNS (meaning you can access internal vm by their name (ping machine-name))
        * Can also choose an custom internal IP if you want when creating the VM
        * One IP per CPU -> Machine can be the bridge across different network
    * Does not change even if the instance is stopped
* External
    * Allocated from pool (ephemeral) -> loose it if you shutdown the machine
    * Reserved (static) -> Billed more when not using the address
    * Don't have DNS, you must provide one

## IP mapping

External IP is mapped to internal address transparently by VPC. Each instance has a host name that can be resolved to an internal IP address.

Hostname = instance name. `hostname -f`

`ifconfig` only displays the internal IP address
* The instance is not aware of the external IP addresses affected to it.

If you delete and recreate an instance, the internal IP can change. This can break connections with other machines when using the IP.
However, the DNS always point the specific instance, no matter its IP address. Each instance has a metadata server, that also acts as a DNS resolver
for that instance.
The metadata server handles all DNS queries for local network and routes all others to Google public DNS servers.

To match external with internal, the instance stores a lookup table.

Alias IP ranges.

For External IP addresses communication:
* The remote host goes through the Google edge routers.
* Can use the external IP addresses
* Or like everything on the internet, go over a DNS resolution, for instance: Cloud DNS (managed DNS service offers by Google, with 100% availability.)

alias IP ranges:
* Configure IP ranges that map to a specific service (containers, or servers)
* Kind of a subnet in the subnet

## Routes and Firewalls
Every network has routes. Direct packets across subnets.

Create special routes to change the basic route. Firewalls must also allow the packet. A route is not enough to make sure the packets arrived at the destination.

The routing table directs the traffic to the proper instances:
* Egressing a MV
* Most specific first
* Created when a subnet is created
* Enable VMs communication on the same network
* Destination is in CIDR notation IP/XX
* Traffic delivers only if it matches a firewall rules.

* Routes are the roads, firewall rules are the toll.
* Route is created when subnet is created
* A route is applied to an instance if the network and the instance tags match.
   * If not tag specified, applies to all compute engine in the network
* Compute engines uses this routes collection to create internal read-only routing tables

Firewalls:
* Protect from unapproved connections.
* Allow inbound (ingress) or outbound (egress) connection
* Connection are allowed or denied at the instance level
* Stateful: all subsequent traffic in either direction are allowed. Once a connection in a way is established, every packets exchanged in that connection are allowed
* Shared and exists across individual instances
* Even if all firewall rules are deleted, there is still always a :
    * deny all ingress rules
    * allow all egress rules
* rules are composed of:
    * direction : inbound (matches ingress rule) or outbound (matches exgress rule)
    * Source for ingress, or destination for egress
    * Protocol and port of the connection. Can be a set of port and IP CIDR
    * Action: Allow or deny packets
    * Priority: to order the firewall rules
    * Assignment: can be assigned to every instance, or only some specific ones

## Pricing
* Ingress: No charge
* Egress to same zone (internal IP address): no charge
* Egress to google products: No charge
* Egress to a different GCP service (within same region): no charge
* Egress between zones in the same region: 0.01$ (per GB)
* Egress to same zone (external IP address) : 0.01$ (per GB)
* Egress between regions with the US and Canada: 0.01$ (per GB)
* Egress between regions, not including traffic between US: depends on the region

Charge for static and ephemeal IP addresses:
* Static (assigned but unused) : 0.01$ per hour
* Static and ephemeral in use on standars VM: 0.004$ per hour
* Static and ephemeral in use on preemtible VM: 0.002$/h
* Static and ephemeral IP addresses attached to forwarding rules: No charge

Pricing can always change. See last pricing.
Use the pricing calculator, helps you to anticipate your billings.

## Labs:

mynet-eu-vm: 10.132.0.2 34.77.111.248
mynet-us-vm: 10.128.0.2 35.193.119.101

```
gcloud compute --project=qwiklabs-gcp-03-47b310cbd4a4 firewall-rules create managementnet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=managementnet --action=ALLOW --rules=tcp:22,tcp:3389,icmp --source-ranges=0.0.0.0/0
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp --direction=INGRESS --priority=1000 --network=privatenet --action=ALLOW --rules=tcp:22,tcp:3389,icmp --source-ranges=0.0.0.0/0
gcloud compute instances create privatenet-us-vm --zone=us-central1-c --machine-type=f1-micro --subnet=privatesubnet-us
gcloud compute instances list --sort-by=ZONE
```

## Common network designs

* Availability: Have multiple instances in multiple zones of the same region. 
    * easier to manage with Instance groups
    * They belong to the same network, therefor it is easy to make the machine communicate, and not more expensive

* Globalization:
    * Putting in many regions, you increase the robustness to the system. Higher degree of failure
    * Loadbalancers to have users communicating with the closest application, reducing latency and improving response time
    
* Bastion Host Isolation:
    * single point of entry to communicate with the internal system.
    
## Compute engines
Shared CPU with other VM using the micro, to lower the cost.
Choose CPU, memory, discs and networking are the main option

Usecase : Any general workload. Portable and easy to run in the cloud.
Container like kubernetes could be a bit different than what we are used to.

* Machine rightsizing
    * Recommendation engine for optimum machine size
    * Stackdriver statistics
    * New recommendation 24hours after VM create or resize
* Global load balancing (multi regions availability)
* Instance metadata / startup scripts
* Availabilty policies
    * Auto restart
    * Live migrate
* Per-second billing
    * sustained used discount (the more you use, the less the hours is expensive)
* Preemptible : 
    * up to 80% discount
    * No SLA
    
Compute options:
* Several different machine types
* Customize if doesn't fit your needs
* Network throughput scales 2Gbps per vCPU (small exceptions)
* Theoretical max of 32 Gbps with 16vCPU or 100Gbps with T4 or V100 GPUs
* a vCPU i equal to 1 hardware hyper thread

Storage:
* Standard, SSD or LocalSSD
    * Standard and SSD scale in performance for each GB of space allocated.
    * SSD : higher number of IO than standard HDD. But is more expensive 
        * 16Tb per instance
    * Local SSD: if faster because it is physically attached to the machine. But the data is not persisted when shutting down the machine
        * use a swap disk. 
        * 8 * 375Gb storage (3TB of local SSD space for each instance)
* Resize disks or migrate instances with no downtime

Networking:
* Default, custom, auto
* Inbound / outbound firewall rules
* Regional HTTPS load balancing
* Network load balancing
* Does not require pre-warming
* Global and multi-regional subnetworks 

## VM Access
Linux SSH
* SSH from cloud shell, or SDK
* SSH from third part client, and generate ssh key pair
* requires rules TCP:22

Windows RDP :
* RDP Clients
* Powershell terminal
* required setting the Windows password
* TCP: 3389

OK with the default network of your project.

Lifecycle:
When we ask for a creation:
1. Provisioning state : CPU, memory and disks are reserved for the instance
    * No running instance yet
2. Staging state: 
    * resources have been acquired and ready for launch
    * Acquiring IP address, booting up system image, booting up the system
3. Running state:
    * Startup script
    * Enable SSH or RDP
    * Actions you can do in this state:
        * Live migrate to another host in the same zone
        * Move instance to different zone
        * Take a snapshot of the persisten disk
        * export the system image
        * Reconfigure metatada
* Stopping state:
    * Go through predefined shutdown scripts
    * Actions available when the instance is stopped:
        * Upgrading CPU
        * Reset the Virtual machine to its initial state
            * Instance remains in the running state while resetting

Impact instance state:
* reset: console, gcloud, API, OS : remains running
* restart: console,  gcloud, API, OS: terminated -> running
* reboot: OS: `sudo reboot` : running -> running
* stop: console, gcloud, API : running -> terminated
* shutdown: OS: `sudo shutdown` : running -> terminated
* delete: console, gcloud, API : running -> N/A
* preemption: automatic -> N/A
    * The machine has 30 seconds to stop. Remember that when writing shutdown scripts for preemptible VMs, otherwise, it will receive a ACPI G3 signal, and the machine will stopped immediatly

Vms availability policy determines the behaviour of the VM during a maintenance operations:
* Configured during creation and while VM is running
* default is Live migrate, but you can choose to stop the machine

Do not pay for a terminated Compute engine memory and CPU resources, but pay for the attached disk or static IP address we use.

Terminated:
* Change machine type
* Add or remove attached disk
* Modify instance tags
* Modify custom VM or project wide metadata
* Remove or set static IP
* Modify VM availability policy
* Can't change the image of a stopped VM

Running VM:
* Can add network tag and labels
* Allow HTTP and HTTPS (which create the firewall rules)
* Can add new disk
* Change the availability policy
* the SSH key for client connection
* can change if we want to delete or keep boot disk on VM deletion
* Can change the networking configuration (IP external and internal)

1. To see information about unused and used memory and swap space on your custom VM, run the following command:
```
free
```
2. To see details about the RAM installed on your VM, run the following command:
```
sudo dmidecode -t 17
```
3. To verify the number of processors, run the following command:
```
nproc
```
4. To see details about the CPUs installed on your VM, run the following command:
```
lscpu
```
5. To exit the SSH terminal, run the following command:
```
exit
```

## CPU and Memory
Create using restful api, cloud shell or GCP console

Machine types: Collection of hardware resources available to a vm instance
* Predefined machine types, avaialble in multiple different classes
    * Standard
        * Balance between CPU and memory
        * 128 persistent disk total of 64TB storage
    * High-memory
        * More memory comparing tp CPU used
    * High CPU
        * More CPU than Memory
    * Memory optimized
        * Required intense use of memory
        * inmemory databases and analytics, SAP HANA and business warehouse workloads, genomic analysis, SQL analysis service.
        * 14 Gb of memory per vCPU
    * compute optimized
        * intensive workloads
        * Highest performance per core on compute engine. Casket lake. 3.8GB gigaherts sustained all-core turbo.
        * C2 machines types offer much more computing power, newer platform, enabling performance tuning.
        * Generally more robust than the N1 high cpu type
    * shared-core
        * 1 vCPU
        * more cost effective for small non intense application
        * f1-micro and g1-small
        * Burst can be handle by using more shared memory during certain temporary spikes
* Custom machine types:
    * Specify CPU and Memory to use
    * Workload not a good fit for predefined 
    * don't need everything provided by the predefined
    * 0.9 and 6.5Gb memory per vCPU. Could be increased with the "extend memory"
    
Region and zones : choose according to the users locations.
* Processor depends on the default processor configured for this zone.

## Pricing 
* Per second billing, with a minimum of 1 minute
* Resource based pricing model
    * vCPU and GB memory are billed separately
* Discount (not combined):
    * sustained use (when using a lot)
        * For more than 25% a month, up to 30%.
        * 50%  usage : 10%  discount
        * reset at the beginning of each month
        * use the pricing calculator for more information
    * Committed use if your usage is predictable
        * Up to 57percent for most and standard machine types
        * up to 70 percent for memory optimized types
    * Preemptible (remember the constraints)

* Recommandation engine:    
    * For custom type after 24hours

* Free usage limits possible

the discount works per usage of CPU and memory. If you have a VM running a full month, you start the first 2 weeks with 4vCPU, and the last 2 weeks with 16 vCPUS, you  get :
* a 30% discount on 4 vCPUs
* a 10% discount on 13 vCPUs

usage: discount
* 50%: 10%
* 75% : 20%
* 100%: 30%

## Special configuration

Preemptible VM: 80% discount.
* Can be terminated at any time
* up to 24hours
* 30 seconds notifications if the machien is preempted.
* No live migrate
* Monitoring and loadbalancing 
* Batch processing job with the preemptible VM.
    * Jobs slows down, but does not completly stop.

Sole tenant nodes:
* You possess your own node, don't share with another customers. Physical compute server. 
* Workloads that requires physical isolation
* Payment processing workloads to meet compliance requirements.
* The same as normal host, but only one customer.
* Operating system license can be imported on the sole tenant node.

Shileded VMs:
* verifiable integrity of your VM instances.
* No compromised by the boot, or kernel level of malware or rootkits.
* Use of secure boot, virtual trusted platform, integrity monitoring.
* Shielded cloud initiatives. Help prevent data exfiltration. Need a shielded image for a shielded VM.

Images:
* Choose boot disk image
    * Boot loader
    * Operating system
    * File system structure
    * Software
    * Customizations
* Public or custom image.
* Custom images:
    * Custom image by preinstalling software
    * from on-prem, or another cloud provider. 
    * From a snapshot also
    
## Boot option
* VM comes with a single root persistent disk, when we choose the image to boot with
    * Durable and can survive (by the disabling the default option when the VM is terminated)

* Persistent disk
    * attached to the VM through the network interface
    * Not physically attached to the machine.
    * Snapshots of this disk, incremental backup
    * SSD or HDD (price is different)
    * Resize disk even when running and attached
    * readonly attached to multiple VMs. Cheaper than replication for individual disk
    * All data are encrypted. Handled by default by GCP.
        * To manage the encryption, you can use your custom keys
        * Create and manage google key
        * Your own key also
  
* Local disk (SSD, HDD or RAM)
    * Physically attached to the VM
    * More IOPS, lower latency, and higher throughput than persistent disk
    * 8 local SSD with 375Gb each, 3Tb total
    * Survived a reset, but a VM stopped or terminated

* RAM
    * fastest type available
    * small data structure.
    * Persistent disk, for backup RAM data.

How to choose disk ?
* HDD just for capacity
* SSD if looking for performance
* Local for more performance: No snapshot, not bootable
* RAM for best, but very volatile (no persistance, lost after a reset): no snapshot, not bootable
 
16 disk attached for shared machine, 128 for another instance

As the disk is not on the machine, the disk IP compete with the network IO. If you are in such a situation, you need more CPU.

Difference between computer and cloud persistent disk
Computer HDD:
* Partition
* repartition disk
* reformat
* redundant disk array
* subvolumes management and snapshot
* Encrypt files before write to disk

Cloud persistence disk:
* Single file system is best
* resize easily
* Resize file system
* Built-in snapshot service
* Automatic encryption

## Common actions

* Use startup and shutdown scripts to start/shutdown the VM
    * Stores the VMs metadata on a metadata server.
    * Recommendation: stores the script in Cloud storage
    * Inject metadata keys to reuse code across VMs instance, like DB initialization with the external IP address
* Move instance to a new zone (Move is not a copy)
    * zone can be deprecated
    * Automate the move by the `gcloud compute instances move` command
* Move to a new region
    * Snapshot of all persistent disk on the source VM
    * Create new persistent disk in destination zone restored from snapshot
    * Create new VM and attached disks in this new zone
    * Assigne static IP
    * Update VM references
    * Delete the snapshots
    
Snapshots:
* Backup critical Data to store into a durable storage solution to meet recovery requirements
    * Stores in cloud storage
* Transfer data from one zone to another
    * Again, changing zone could be for latency reasons, depending on where are located your users
* Transfering data to different disk type
    * Standard HDD to persistent SSD disk

Persistent disk snapshots:
* incremental and automatically compressed. Cheaper to do regular snapshot than occasional full one
* Not available for "Local SSD"
* Stored in cloud storage
    * But not visible in our buckets
    * CRON jobs for periodic incremental backup (schedule backup)
* Can be restored to a new persistent disk
    * Changing region (opening a new region)
    * moving zone
        * Doesn't backup VM metadata, tags... 

Resize persistence disk. Improve IO performance. No snspashots needed. No shrink possible.


Notes:
* To attach a disk, use the Console to attach it, but then you have to mount it
```
sudo mkdir -p /home/minecraft
sudo mkfs.ext4 -F -E lazy_itable_init=0,\
    lazy_journal_init=0,discard \
    /dev/disk/by-id/google-minecraft-disk
sudo mount -o discard,defaults /dev/disk/by-id/google-minecraft-disk /home/minecraft
```