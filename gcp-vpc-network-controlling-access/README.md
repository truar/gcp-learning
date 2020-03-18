# VPC Networks - Controlling Access
The overall idea is to use tag names on server an IAM account to create new kind of firewall rules
in order to connect our machines together.

Create the first engine instances
```
gcloud compute instances create blue \
    --zone=us-central1-a \
    --machine-type=f1-micro \
    --tags=web-server
```
```
gcloud compute instances create green \
    --zone=us-central1-a \
    --machine-type=f1-micro
```

Create the firewall rules to HTTP and ICMP on server tagged web-server
```
gcloud compute firewall-rules create allow-http-web-server \
    --direction=INGRESS \
    --priority=1000 \
    --network=default \
    --action=ALLOW \
    --rules=tcp:80,icmp \
    --source-ranges=0.0.0.0/0 \
    --target-tags=web-server
```

Now, we want to create a new VM, in the same network, and check if it can connect to the other VMs using:
- internal IPs. This will work as the VMs are in the same network and there is a firewall rule to allow all
- external IPs. This will work only on blue as there is a firewall rule allowing http on web-server tagged instance.

```
gcloud compute instances create test-vm \
    --machine-type=f1-micro \
    --subnet=default \
    --zone=us-central1-a
```

By default, a compute engine is connected to a google instance account. In my case : `49043265818-compute@developer.gserviceaccount.com`
If you try to execute some gcloud command, some may fails:
```
# OK: check whoami on google
gcloud auth list
# KO: insufficient Permission
gcloud compute firewall-rules list
# KO: insufficient Permission
gcloud compute instances list 
```

Service account with Role: Compute Network Admin:
* List available firewall rules
* Not modify/delete

Compute Security Admin:
* Can update/modify firewall rules 
*

Clean up
```
gcloud compute instances delete blue --zone=us-central1-a
gcloud compute instances delete green --zone=us-central1-a
gcloud compute instances delete test-vm --zone=us-central1-a
gcloud compute firewall-rules delete allow-http-web-server
gcloud iam service-accounts delete network-admin@gcp-associate-cert-prep-truaro.iam.gserviceaccount.com
```