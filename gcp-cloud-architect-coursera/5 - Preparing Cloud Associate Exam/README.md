# Preparing Cloud Associate exam

## Billing management

In order to change the billing account of a project, you must be:
* An owner of the project
* AND a billing Administrator of the destination billing account

Projects are linked to billing accounts

## Planning and configuring a Cloud Solution
### 1. With new projects, you want budgets
* => Use the pricing calculator
* Price are not 100% accurate, it may varies depending on the actual usage

### 2. Planning and configuring compute resources
* Select the appropriate: 
    * App engine
        * Use when you need: To focus on code, Developer velocity, To minimize operational overhead
        * Typical use cases: Websites, Apps, Gaming Backends, IoT apps 
    * Compute engine
        * Use when you need: Complete control, ability to make OS level changes, Move to cloud without rewriting code, use custom images
        * Use cases: Any workload requiring a specific OS or configuration, On-premises software that you want to run in the cloud
    * Kubernetes Engine
        * Use when you need: No OS dependencies, increase velocity and operability, containers in production
        * Use cases: Containerized workload, Cloud native distributes systems, Hybrid applications

### 3. Planning and configuring storage options
Data Storage:
* CloudSQL
* Cloud Spanner
* Cloud BigTable
* Cloud firestore/datastore
* Cloud filestore
* Cloud storage
    * Storage class (standard, Nearline, Coldline, Archive)

### 4. Planning and configuring network resources

## Managing Compute Engine resources

### Managing Compute Engine
Image family: 
* If you regularly update a custom image with newest software configuration for instance,
Use a family so that your template does not have to be modified when you release a new versions of the custom image
* The image family always point to the latest image version

Create disk images from:
* A persistent disk even while attached to a VM
* A snapshot of a persistent disk
* another image in your project
* Image shared among projects
* Compressed RAW image in Cloud storage

### Managing Kubernetes engine

* GKE manages compute engine instances to make sure your kubernetes cluster has enough instances to do what you need.
* Then, run the `kubectl` command to manage your node together
* Use `yaml` file (just like Deployment manager) to tell Kubernetes what you want, and it will figure out how to do it.

By default, PODS are only available inside the GKE cluster. To make them available, 
you have to create a kube loadBalancer
```shell script
# Create a service with a fixed IP for your cluster in the GKE network (subnetwork ?)
kubetctl expose deployments nginx --port=80 --type:LoadBalancer
```
This command creates a Network LoadBalancer to expose your cluster with an External IP

```yaml
# Generate the config yml file
kubetctl get pods -l "app=nginx"
```

### Managing App engine resources

* Can use dynamic or resident instances => Always run an app engine version
    * Dynamic: scale on needs
    * Resident: fixed instance number
    
### Managing data solutions

Cloud Storage: Lifecycle management on object in a bucket
* Downgrade the storage class of objects older than 365 days
* SetStorageClass
    * Age
    * CreatedBefore
    * isLive
    * Matches Storage Class
    * Number of newer versions
    
### Managing Network resources

* Expand the CIDR of a subnet
* Can't be shrunked, or replace, but can expanded a subnet
* Longest mask is /29 (4 adresses are used by default in a subnet)

### Monitoring and Logging

Some GCP services already have the stackdriver included:
* App engine (both flexible and standard)
* Kubernetes engine

For others, install monitoring agents.

## IAM Module

* Google account
* service Account
* Google group
* G Suite domain
* Cloud identity domain
    * Don't have access to G-suite applications
    
To create custom roles, you must be granted the iam.roles.create permission

### Monitoring and Logs

Cloud audit logs: who did what, where and when, within the GCP projects
* Admin Activity
* System Events
* Data Access

Information:
* Resources (like VM instances)
* Service: individual GCP products (like Compute engine, Cloud SQL...)
    * Identified by name

Viewed from the stackdriver interface.

Most services consider
* request latency: how long it takes to return a response to a request as a key SLI. Other common SLIs include the error rate, often expressed as a fraction of all requests received and system throughput, typically measured in requests per second. Another kind of SLI important to SREs is availability or the fraction of the time that a service is usable. It is often defined in terms of the fraction of well-formed requests that succeed.
* Durability: the likelihood that data will be retained over a long period of time is equally important for data storage systems. The measurements are often aggregated: i.e., raw data is collected over a measurement window and then turned into a rate, average, or percentile.


| SLI |	Metric | Description |	SLO |
|-----|--------|-------------|------|
| Request latency |	Front end latency |	Measures how long a user is waiting for the page to load. A high latency typically correlates to a negative user experience |	99% of requests from the previous 60 minute period are services in under 3 seconds |
| Error rate |	Front end error rate |	Measures the error rate experienced by users. A high error rate likely indicates an issue.	| 0 Errors in the previous 60 minute period |
| Error rate |	Checkout error rate |	Measures the error rate experienced by other services calling the checkout service. A high error rate likely indicates an issue. |	0 Errors in the previous 60 minute period |
| Error rate |	Currency Service error rate	| Measures the error rate experienced by other services calling the currency service. A high error rate likely indicates an issue.	| 0 Errors in the previous 60 minute period |
| Availability| Front end success rate |	Measures the rate of successful requests as a way to determine the availability of the service. A low success rate likely indicates that users are having a poor experience.	|99% of requests are successful over the previous 60 minute period |
