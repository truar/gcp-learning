# Google Cloud Programming - Challenge labs

## Task 1: Create a project jumphost instance

Create a `Compute Engine` (virtual machine) with a limited machine-type.
```
gcloud compute instances create nucleus-jumphost \
    --machine-type f1-micro \
    --zone us-east1-b
```

GCP items created:
 - 1 Compute engine

## Task 2: Create a Kubernetes service cluster

 1. Create the `Kubernetes Engine` (Kubernetes cluster) with the default value:
 - 3 Compute Engines (nodes)
 - machine type = n1-standard-1
```
gcloud container clusters create nucleus-cluster
```
 2. Authenticate to enable the `kubctl` command connected to your clusters named `nucleus-cluster
```
gcloud container clusters get-credentials nucleus-cluster
```
 3. Create the `Workload` (application) and deploy it on the nodes
```
kubectl create deployment nucleus-server --image=gcr.io/google-samples/hello-app:2.0
```
 4. Create a `LoadBalancing` rule (Network > LoadBalancing) item to expose the API on port 8080
```
kubectl expose deployment nucleus-server --type=LoadBalancer --port 8080
```
 5. After couple of seconds, get the IP check your service : http://104.196.132.86:8080
```
kubectl get service
```
> NAME             TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)          AGE<br/>
> kubernetes       ClusterIP      10.7.240.1     <none>           443/TCP          2m15s<br/>
> nucleus-server   LoadBalancer   10.7.248.109   104.196.132.86   8080:32533/TCP   44s 

GCP items created:
 - 1 Kubernetes engine
 - 1 Workload
 - 3 Compute engines
 - 1 LoadBalancing rules
 - ...

## Task 3: Setup an HTTP load balancer

### Create the Compute engine and make them accessible
 1. Create a file to automatically install nginx onto your Compute engines
```
cat << EOF > startup.sh
#! /bin/bash
apt-get update
apt-get install -y nginx
service nginx start
sed -i -- 's/nginx/Google Cloud Platform - '"\$HOSTNAME"'/' /var/www/html/index.nginx-debian.html
EOF
```
 2. In order to easily create the `Instance group` and have the Compute engine all created the same way, create an `Instance template`
who will be executing the startup script. Limit the machine-type.
```
gcloud compute instance-templates create nucleus-template \
     --machine-type=f1-micro \
     --metadata-from-file startup-script=startup.sh
```
 3. Create a `Target Pool` to have a single entry point into the future `Instance group`
```
gcloud compute target-pools create nucleus-pool
```
 4. Create the `Instance group` connected to the `Target pool` previously created. 2 compute engines must be created.
 The goal of the `Instance group` is to keep align the compute engines.
```
gcloud compute instance-groups managed create nucleus-group \
         --base-instance-name nucleus-webserver \
         --size 2 \
         --template nucleus-template \
         --target-pool nucleus-pool
```
 5. Create a firewall rule to allow HTTP 80 traffic.<br/>
 Why not using the `Instance template` and use the option `Allow HTTP traffic` ? What is the difference ?
```
gcloud compute firewall-rules create www-firewall --allow tcp:80
```

### Create the HTTP LoadBalancer
 1. To make sure the LoadBalancing will not hit a failed server, create a `Http Health Check`
``` 
gcloud compute http-health-checks create http-basic-check
```
 2. Make the `Health check` checking the `Instance group` on port 80
```
gcloud compute instance-groups managed \
       set-named-ports nucleus-group \
       --named-ports http:80
```
 3. Create a `Backend service` server that will use the `Health Check` to know when a server in not responding, 
 and not Load balancing the request to it.
```
gcloud compute backend-services create nucleus-backend \
      --protocol HTTP --http-health-checks http-basic-check --global
```
 4. The `Backend server` is connected to the `Instance group` to forward the HTTP request to it.
```
gcloud compute backend-services add-backend nucleus-backend \
    --instance-group nucleus-group \
    --instance-group-zone us-east1-b \
    --global
``` 
 5. Create a `Url Map` to redirect the request onto the proper `Backend server` depending on the endpoint requested.
 In this case, there is no special rule, so every incoming request will be forwarded to `nucleus-backend`.
```
gcloud compute url-maps create web-map \
    --default-service nucleus-backend
```
 6. Create a `Proxy` that will intercept the request and then call the `Url Map`. This a HTTP proxy.
```
gcloud compute target-http-proxies create http-lb-proxy \
    --url-map web-map
```
 7. Make the proxy forwarding the HTTP request on port 80
```
gcloud compute forwarding-rules create http-content-rule \
        --global \
        --target-http-proxy http-lb-proxy \
        --ports 80
```
 8. Retrieve the IP to access your application
```
gcloud compute forwarding-rules list
```
 
GCP items created:
 - 1 Instance template
 - 1 Target Pool (load balancing ?)
 - 1 Instance group
 - 2 Compute engines
 - 1 LoadBalancing rules
 - 1 firewall rule
 - 1 health check
 - ...

