# Multiple VPC lab
qwiklabs : https://www.qwiklabs.com/focuses/1230?parent=catalog
Create network with default compute instance
```
gcloud compute networks create default \
     --subnet-mode=auto \
     --bgp-routing-mode=regional

gcloud compute networks create mynetwork \
    --subnet-mode=auto \
    --bgp-routing-mode=regional

gcloud compute firewall-rules create mynetwork-allow-icmp \
    --description="Allows ICMP connections from any source to any instance on the network." \
    --direction=INGRESS \
    --priority=65534 \
    --network=mynetwork \
    --action=ALLOW \
    --rules=icmp \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create mynetwork-allow-internal \
    --description="Allows connections from any source in the network IP range to any instance on the network using all protocols." \
    --direction=INGRESS \
    --priority=65534 \
    --network=mynetwork \
    --action=ALLOW \
    --rules=all \
    --source-ranges=10.128.0.0/9

gcloud compute firewall-rules create mynetwork-allow-rdp \
    --description="Allows RDP connections from any source to any instance on the network using port 3389." \
    --direction=INGRESS \
    --priority=65534 \
    --network=mynetwork \
    --action=ALLOW \
    --rules=tcp:3389 \
    --source-ranges=0.0.0.0/0

gcloud compute firewall-rules create mynetwork-allow-ssh \
    --description="Allows TCP connections from any source to any instance on the network using port 22." \
    --direction=INGRESS \
    --priority=65534 \
    --network=mynetwork \
    --action=ALLOW \
    --rules=tcp:22 \
    --source-ranges=0.0.0.0/0

gcloud compute instances create mynet-us-vm \
    --zone=us-central1-c \
    --machine-type=f1-micro \
    --subnet=mynetwork

gcloud compute instances create mynet-eu-vm \
    --zone=europe-west1-c \
    --machine-type=f1-micro \
    --subnet=mynetwork
```

Create the managementnet network with its subnet
```
gcloud compute networks create managementnet \
    --subnet-mode=custom

gcloud compute networks subnets create managementsubnet-us \
    --network=managementnet \
    --region=us-central1 \
    --range=10.130.0.0/20
```

Create the privatenet network with its subnet
```
gcloud compute networks create privatenet \
    --subnet-mode=custom

gcloud compute networks subnets create privatesubnet-us \
    --network=privatenet \
    --region=us-central1 \
    --range=172.16.0.0/24

gcloud compute networks subnets create privatesubnet-eu \
    --network=privatenet \
    --region=europe-west1 \
    --range=172.20.0.0/20
```

List the available networks
```
gcloud compute networks list
```
List of all subnets by VPC
```
gcloud compute networks subnets list --sort-by=NETWORK
```
Create firewall rules allowing ingress packets on many ports, on the network managementnet
* Allow SSH (tcp:22)
* Allow ICMP 
* Allow RDP (tcp:3389)
```
gcloud compute firewall-rules create managementnet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=managementnet \
    --action=ALLOW \
    --rules=tcp:22,tcp:3389,icmp \
    --source-ranges=0.0.0.0/0
```
Create firewall rules for privatenet
* Allow SSH (tcp:22)
* Allow RDP (tcp:3389)
* Allow ICMP
```
gcloud compute firewall-rules create privatenet-allow-icmp-ssh-rdp \
    --direction=INGRESS \
    --priority=1000 \
    --network=privatenet \
    --action=ALLOW \
    --rules=icmp,tcp:22,tcp:3389 \
    --source-ranges=0.0.0.0/0
```
List all firewall rules rules by VPC
```
gcloud compute firewall-rules list --sort-by=NETWORK
```

Create 2 VMs 
```
gcloud compute instances create managementnet-us-vm \
    --zone=us-central1-c \
    --machine-type=f1-micro \
    --subnet=managementsubnet-us

gcloud compute instances create privatenet-us-vm \
    --zone=us-central1-c \
    --machine-type=n1-standard-1 \
    --subnet=privatesubnet-us
```
List VMs by zone
```
gcloud compute instances list --sort-by=ZONE
```

Check connectivity between compute engine instances
```
# ssh on an instance
ssh -i ~/.ssh/my-key 34.66.251.254
# Ping all external addresses : all works
ping -c3 146.148.29.157
ping -c3 35.223.193.87
ping -c3 35.226.49.79
```
I can ping any external IP addresses thanks to my firewall rules

But I can only ping the mynet-eu-vm internal IP from mynet-us-vm because they belong the the same VPC (even in different subnets).
My intuition was correct, if you want to communicate between VPC using internal IP addresses, use VPC peering or VPN

Create a VM with multiple network interfaces (depending on the number of cores, which is 4 for the lab) (don't know how to do it with the command line yet)
* In the console, one interface per network => 3 (privatenet, managementnet, mynet)
```
gcloud compute instances create vm-appliance \
    --zone=us-central1-c \
    --machine-type=n1-standard-4 \
    --subnet=privatesubnet-us \
```

Check that this new VM, sharing multiple VPC, can communicate to all of the others VMs
```
# OK (same region)
ping -c3 10.130.0.2
# KO (different region)
ping -c3 10.132.0.2
# OK (same region)
ping -c3 10.128.0.2
# OK (same region)
ping -c3 172.16.0.2
```
Unless configured otherwise, the route to reach a subnet in another region on a multiple interface instance is not created.
Therefore, when trying to ping 10.132.0.2, the default route is used (the one using eth0)

Cleanup:
```
gcloud compute instances delete vm-appliance
gcloud compute instances delete managementnet-us-vm
gcloud compute instances delete privatenet-us-vm
gcloud compute instances delete mynet-us-vm
gcloud compute instances delete mynet-eu-vm
gcloud compute firewall-rules delete managementnet-allow-icmp-ssh-rdp 
gcloud compute firewall-rules delete privatenet-allow-icmp-ssh-rdp 
gcloud compute firewall-rules delete mynetwork-allow-ssh 
gcloud compute firewall-rules delete mynetwork-allow-icmp
gcloud compute firewall-rules delete mynetwork-allow-internal
gcloud compute firewall-rules delete mynetwork-allow-rdp
gcloud compute networks subnets delete privatesubnet-us --region=us-central1
gcloud compute networks subnets delete privatesubnet-eu --region=europe-west1
gcloud compute networks subnets delete managementsubnet-us --region=us-central1
gcloud compute networks delete privatenet
gcloud compute networks delete managementnet
gcloud compute networks delete mynetwork
```