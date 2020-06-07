# Week 1
## Introduction

Cloud computing is :
* Get resources on demand, no human intervention, through an interface
* Access those resources over the network anywhere you want
* The provider has a big pool and can allocate processors to client on demand
* Resources are elastic, you have given what you need
* Customers pay only for what they use.

Regions and Zone :
* A zone is the finest grain level of a geographical data center (not just a GCP Data center)
* A region is composed of many zones (Europe Region is composed of 3 to 4 zones)
* A service can be multi-region, like Google Cloud Storage, giving automatic redundancy to the data
* Cluster can be separated by 160 km within Europe
* Zones & Regions: less latency to customers of your app. Redundancy against natural disaster.

Google uses OpenAPI not to lock in customers, but let them choose the change the provider 
if Google is no longer the best provider for them.
* BigTable is based on HBase interface, which gives coders the possibility to change BigTable to Apache HBase
* DataProc offers Hadoop

* IaaS offerings provide raw compute, storage, and network organized in ways that are familiar from data centers. 
* PaaS offerings, on the other hand, bind application code you write to libraries that give access to the infrastructure your application needs.
* All the zones within a region have fast network connectivity among them

Google services :
* Compute
    * Compute engine, kubernetes, app, run, functions
* Storage
    * BigTable, Cloud Storage (bucket), SQL, Spanner (same perf noSQL, but transactions, low latency, SQL), 
    Datastore (noSQL table), FileStore (filesystem)
* Big Data
    * BigQuery, PubSub (messaging), DataFlow, DataProc, Datalab
* Machine Learning
    * Natural languages, Vision, Machine learning, Speech, Translate
    
Google security:
* Hardware infrastructure: design and provenance. Security boot. Google developed a new chip called Titan for security purposes
* Service deployment: Encryption of inter-service communication
* User identity: 2 auth factor. Login Key
* Storage services: All HDD and SSD are encrypted

## Project

Projects are the main way you organize the resources you use in GCP. 
Use them to group together related resources, usually because they have a common business objective

The principle of least privilege is very important in managing any kind of compute infrastructure, whether it's in the Cloud or on-premises

Four ways to interact with GCP management layers:
* Web console
* SDK
* API 
* Mobile app

* Google is responsible for securing its infrastructure.
* We are responsible for securing our data
* Google helps with best practices, templates, products and solutions

## Google hierarchy system
* All running resources are grouped into projects.
* Projects can be organized into folders, themselves organized into folders...
* All folders and projects used by our organization can be brought under a Organization Node.

Projects:
* have a name and an ID we assign. (id unique across GCP)
* have different owners and users. They are built and managed separately.
* are the basis for enabling google API, enabling billing 

Folders:
* represents teams, department, applications or enviroment
* Let teams have the ability to delegate administrative rights 
* The resources in a folder inherits the IAM policies from the folder
* Folders requires an Organization Node

Organization Nodes:
* Centralize visibility on how resources are being used, and apply policy centrally.
* Specific roles to an organization:
    * organization policy administrator : only people with this roles can change policies
* GCP Suite Domain already have a Organizational node
* Otherwise, use Google Cloud Identity to create it.
* All policies set at organizational level are automatically inherited to every resources below. 
* The more generous policicy is the one that take effect. Which means, if a user has the right to do an actions on every resources under the organization,
then the projects can't override that policy. You can't take away what's been given.

## Identity Access Management
* `Who`
    * Google account, Service account, G Suite organization, Cloud Identity Domain
* can do  `what`
    * IAM Role => collection or `permissions`
       * Example : compute instances: create, modify, delete, start, stop => A role to manage all this permissions.
* on which `resources`
   
3 kinds of role in GCP:
* Primitive roles. Broad. Can do what on every resources.
    * Viewer = view permissions
    * Editor = viewer + edit permissions
    * Billing administrator
    * Owner = Editor + IAM management + Billing 
* Predifined roles : Can do what on a particular service (compute engine, app engine, BigTable...)
    * Even role to an individual BigTable database instances.
    
Compute instance example:
* Instance Admin Role
    * compute.instance.delete
    * compute.instance.get
    * compute.instance.list
    * compute.instance.setMachineType
    * compute.instance.start
    * compute.instance.stop
    * ...
Apply roles to a GCP Groups. Which will grant the role to every users in this role.

Given some companies policies, organization, you can define custom roles. If no predefined roles fit my needs:
* Create a InstanceOperator
    * start/stop/get/list the instances, but not reconfiguring them.

Custom roles :
* Only to projects or organizations, not folder

Use google service account if a CE need to have access to a storage service, and only that machine, not the entire internet.
It is also a resources, on which you can apply Policy (who can change the service, his roles...)

## Interacting with GCP
Like said in the introduction, there is 4 ways:
* Web based console
* SDK with `gcloud`
* API
* Mobile app

The end users of the applications won't use it. Manage all resources and services they use.

SDK: also available as a Docker image
* `gcloud`: main interfaces for most of google resources @ services
* `gsutil`: to manage Cloud Storage
* `bq`: to manage BigQuery

API: 
* JSON
* OAuth2 to authenticate

By default, the API are disabled, making sure you won't use a service not on purpose.

Mobile app for android and Ios to manage resources on GCP. Create dashboard to quickly get the information you need.

## Google Marketplace
Launch predefined applications developed by others people.

Not extra fees, just regular fees for the resources being deployed.

Sometimes, extra fees from third part company, licence cost, or everything. But you have the monthly estimates.

## Virtual Private Cloud
Use the default VPC (default) or create yours. Inside the same VPC, machine can talk to each other. 
* create static route to forward traffic to specific destination
* Create firewall rules to ensure access to your network
* A VPC is worldwide, and have subnets by region
* resilient thanks to region level

## Compute engine
No upfront investment. Create a Virtual machine, using console, or `gcloud`. 

Based in images, either ones from google, or one you created.

Choose memory and cpu by finding a predefined machine type, or if we don't find what we need, create your own configuration.
If needed, use GPU (for machine learning, dashboarding)

Persistence storage : 
- SSD: high performance scrath space. But is terminated with the VM
- storage: sensitive data that must last (default)

Boot image : Linux or Windows ready to go. Own images as well.
Installing packaging on start boot, by passing start boot.

Take a durable Snapshots of the disk. Migrate VM to another region, or just simple backup (remember all the snapshot part, with the scheduling).

Choose a preemtible VM, that can be terminated by GCP when the resources are needed elsewhere.
It is cheaper. But think your job as restartable.

AutoScaling feature for Compute Engine (without instance group ?)


## VPC capabilities
They have routing tables. Forward traffic within the same network.
No external IP address needed, even in different zones. 

VPC gives a global distributed firewall. You just have to give the firewall rules (like allowing incoming HTTP traffic).
Use tag to allow/restrics access to tagged VM (like http-server tag)

VPC belongs to GCP projects.
Several GCP projects, and VPC needs to talk to each other.
Use peering connection, with VPC Peering. 
But with more IAM possibilities, use shared VPC.
Cloud LoadBalancing to balance traffic across instances.
* Fully distributed, software defined.
* Don't manage them.
* HTTP/HTTPS, SSL. TCP / UDP
* cross-region load balancing.


* HTTP/S, TCP/SSL or UDP load balancer: intented to balance traffic from the internet inside the VPC. They are external Load Balancer.
* Use Internal Load Balancer if intended to balance traffic between front and backend, inside the same network.

Can use Cloud DNS to help the world finding our applications. Cost effective way. available ti users.
Redundant across the world.
Manage them with regulat google tool.

Cloud CDN : Accelerate content delivery to our user, by using a distributed cache, close to the users, to reduce latency.
Can reduce cost by reducing the load.

Connecting network together : Virtual Private Network, over the IPSEC protocol.
To make the routing dynamic, use Cloud Router: networks VPC and on premises can exchange information.

No internet (given needs) => direct peering possible. Require a router inside the GCP Data center. (no Google SLA)
If you can't do so, use carrier peering : a provider connects your system to google.
If you need extra speed, use dedicated interconnect.


## Cloud Storage
Object storage : 
* NOT a Filesystem system with a hierarchy of folders
* NOT a block storage, with operating data on blocks

We receive an ID, like URL and then we can retrieve the data, and we don't care how it is stored. 
Provide high availabilty, high durability, fully managed scalable service.

* Store assets for a website
* Store file for users direct download
* ...

Buckets store the object. We create new versions, don't edit them in place. We upload new versions, we can't edit them.
Data are encrypted before being written on the disk.
Default, data transit is using HTTPS.

You can move onwards to others GCP services. A bucket has a global unique name. A geographic location. And default storage class.
Control access to objects and buckets. 

IAM is sufficient for most of the time. It controls who can do certain operations on the bucket (upload, download, create...)
Access control List (ACL) that offers final control -> Who can access a particular objects.
ACL is two pieces of information:
* A scope => who can perform the specified actions
* A permission : what action can be performed

By default, objects are immutable, unless we activate the `versioning` of the bucket.
* So upload a new versions, and you can't recover
* With versioning, see the object history and recover an older version

Lifecycle management policies: 
* Delete objects older than 365 days
* Delete object prior to january 2013
* Keep only most recent versions of each object

### Storage classes
From most expensive to cheapest:
* Multi-regional buckets: High performance. more redundancy. SLA: 99.95%.
    * Store frequently accessed data: data parts of game or mobile app. Website content, interactive workload
* Regional Buckets: High performance SLA: 99.90%. Cheaper than multi.
    * Store data close to the compute engines, kubernetes clusters.

* Nearline: Backup.SLA: 99.00%
    * Infrequently access, like once a month for analysis, that is a great choice. 30 days minimum storage duration
* Coldline: Archive. SLA: 99.00%
    * Archiving, online backup, disaster recovery. Access once a year. 90 days minimum storage duration

All are accessed within milliseconds.

Pricing : storage + data transfer (nearline and coldline). 

`gsutil` to manage cloud storage. Or drag and drop.
But to upload big files (like TB) : GCP provides the storage transfer service. Schedule extract from other cloud provider,
from different storage region of from HTTPS endpoints.

Transfer service : rackable, high capacity, leased from google.

## Cloud BigTable
BigData cloud NoSQL tables.

No all the rows might need to have the same column.
single lookup key. Like a persistence hatch table.

Need a rowkey to access Data. High availability, fully managed (scalable), Billions of rows

Used for :
* IoT
* financial data analysis
* user analytics.

Same API as HBase, gives us the choice to change.

Why BigTable:
* Scalability. You have to do it on your own with your HBase. Increase machine count with no downtime
* upgrades and restart transparently.
* IAM to apply restriction.
* Same services ued by others gSuite tool (gmail, maps...)
* Interacts with others GCP services.

Serve data to dashboard. Connects with:
* streaming applications: Cloud dataflow, Spark streaming, storm
* API
* Batch processing: Hadoop Map/reduce, dataFlow or spark


## Cloud spanner
SQL and transactional Databases

Use schema to keep data consistent and correct. Transactions.

MySQL or PostgreSQL provided by google, with TB of storage.
Run a server inside a compute engine machine.
But more benefits with cloud sql:
* several replicas services. Automatic failover, multiple zone
* Backup on demands or schedule
* Scale vertically (changing machine type), and horizontally (add more machines)
* Security perspective: firewalls rules, customer data encrypted, temporary files, backup
* Interconnections with other google services
* Supports SQL Workbranch, Toad, or others.

If need more scalability horizontally, consider Cloud Spanner.
* Transactional consistency at global scale
* Schemas, SQL
* automatic synchronization replication for High availability.

Spanner is a good choice for:
* Sharding databases for high performance
* outgrown relational database
* transaction concurrency, global data and strong conssitency

=> Financial or inventory apps.

## Cloud Datastore / firestore
Designed for application backend. This is also a NoSQL table.
Store structure data for app engine apps.

Fully managed service:
* Automatic sharding and replication. High availability.
* durable databases
* scalas automatically
* Offers transactions, unlike BigTable
* SQL queries like
* Free first quota

## Comparing Storage options
OLTP: OnLine Transaction Processing
OLAP: OnLine Analysis Processing

## Kubernetes engine

IaAS, save infra chores. Platform as a service offering.
Based on Containers:
* Give you independent scalabilty of worloads
* Abstraction of the operation system and hardware
* Starts quickly
* Need on hosts: supports containers and a container runtime.
* Scale like Paas, and nearly same flexibility as Iaas
* Makes your code very portable. Deploy from your laptop to others instances without rebuilding anything.
* Deploy dozen of units depending on workloads

Container communicates over network fabric. 
Independent containers growing and evolving.
Rolling update

Docker to build. But also: Cloud Build. Managed services to build containers.
Upload the images on a registry, like the Google Container Registry.

## Kubernetes
* Open source orchestrator for containers to manage and scale apps
* API to talk with it, with security control
* `kubectl` to manage the cluster

Kubernetes deploys apps on a set of `nodes` called a `cluster`
* In kubernetes, a node is a running instance
* In GCP, nodes are running virtual machines running in Compute engine

Describe the applications and how they interact and kubernetes does the rest.

GKE clusters can be customized:
* machine types, number of nodes and network settings

`Pods`: a set of related containers. It is the smallest deployable units. Sometimes, just a service, sometimes an entire applications

* One container per Pod usually (better scalability)
* Share volumes.
* Each pod has an IP address and a set of ports.
* Inside a Pod, containers can communicate using localhost, thus, they don't care on which nodes they are deployed on.
* `Deployment` represents group of replicas of the same pods. It keeps the pods running.
    * `kubectl run`
* By default, pods in a deployment are only accessible inside the cluster.
* what about internet: connect a load balancer to it. `kubectl expose`
    * Creates a `service` to serve the pods
    * groups a set of pods together.
    * `kubectl get services` to get services public IP
* To scala: `kubectl scale`

Telling command to kubernetes is not the best way to use. The best is to provide a configuration file that tells kubernetes
what we want. And the files can be saved in a version control. Very handy

* `kubectl apply` to use updated config files.
* `kubectl get replicas`
* `kubectl get pods`

Can set the `update strategy`:
* Rolling update: creates new pods of the new version, one by one, waiting for them to bu up before replacing the old pods


## Hybrid and multi-cloud computing
Problems with classic on-premises environment: take from months to years to be able to reallocate power processing (buying new servers, installing apps and dependencies, network configuration...)

But you can't always go from on-premises to cloud computing. So how can you achieve it gradually ?
Move your components at your own pace, and keep part of the systems on your premises

**Anthos** is a hybrid and multi cloud solutions. Anthos framework rests on kubernetes and Google Kubernetes deployed on-prem.

GKE:
* auto-repair
* auto-upgrade
* auto-scaling.

Let's see how to configure an hybrid multi-cloud solutions with Anthos.

On one side, you have a GKE clusters, replicated accross multiple zones, regional clusters for high availability with multiple masters.

On the other side, you install a GKE deployed on prem, best practices configuration already on pre-loaded. A turn-key production grade conformed versions of Kubernetes.
Provide access to Cloud build, container registry, audit logging, and more.

Both are integrated with MarketPlace. Allow to use same configuration on both side of the network.

To have a lifecheck and monitoring the onpremises application, Anthos comes with Istio Open Service, 
and establish a communication with Anthos service Mesh with Cloud interconnect. This way, Anthos can retrieve the app runtime information

StackDriver offers a fully managed login, dashboarding, metrics collections...

Anthos Configuration Management provides a Single Source of Truth for clusters configuration. Kept in the policy repository (GIT)
Located on prem or in the cloud.

## App engine
No server to manage or to provision. Focus only on the development, and AppEngine will run the code.
High availibility, scalability. 

Already working with: 
* NoSQL Databases, 
* in-memory, 
* load balancing, 
* health check, 
* a way to authenticate users.

## App engine Standard environment
Standard is the simpler. Fine-grained auto-scale. Free usage quotas.

Low utilisation might be able to run at no charge !

Use runtime provided by google:
* Java
* Python
* PHP
* Go

Standard environment is not right if we need another language, or a specific runtime environment (like a specific JRE)

They run in a "sand-box":
* Can't write to a filesystem
* All request has 60 seconds timeout
* No arbitrary third party software.

If those constraints don't work for us, choose flexible environment.

You can run & test the application locally using the app engine SDK.
Then, deploy to the cloud using the SDK.

Already working with: 
* NoSQL Databases like firestore, 
* in-memory using mem-cache, 
* searching logging
* user logging
* launch actions not triggered by a request, like task queue and a task scheduler

## App engine flexible environment

If standard doesn't work for us, use flexible.

No sandbox. Let us specify the Docker container we want to use, hosted on compute engines.

Same access as standard environment.

Comparison:
* Standard: faster with a ms up time, no SSH, no local write, no third part libs, network access through app engine. free for "small" apps, automatic shutdown
* Flexible: slower with a minutes to boot, SSH access local writes (not persisted), third part lib, network access, pay for instance hours, no automatic shutdown

Flexible is more expensive, but it allows more things.

The less control : The more control

App engine standard, Flexible, Kubernetes

## Cloud Endpoints and Apigee Edge

GCP can manage the API versioning you could have when exposing API. 
The program can specify the version of the API, and the call iS redirected to the good version.

Cloud Endpoints:
* Easy API exposure
* consumed by trusted developers
* easy way to monitor and logs
* single coherent way for the developer to make the call
* Console API to wrap-up those capabilities
* Supports only app, running on compute instances

Apigee Edge:
* 

## Development in the cloud
Having a Git installed on Google : **Cloud Source Repositories**:
* Git version controls support, for apps running on App , Compute and Kubernetes engine
* IAM permissions on project to protect
* any number of private Git Repositories
* Organize codes associated to a project.
* Sourve viewer

Introduction to Cloud Functions:
* Just write the code (javascript, java...)
* Google do the provisioning
* Triggers on event on cloud storage, http call, or pub/sub
* Some microservices application can be written in Cloud Functions

## Deployment: IaaC
Deployment manager : Use a template to provide the project the same way in many environments for instance.
Recreate in a click your entire project without any manual actions.

Cloud Deployment Manager (file in yml or python => Best for python, more possibilities)

Store those templates in Cloud Source repository. 

## Monitoring: Proactive instrumentation
Stackdrivers is GCP tools for monitoring, logging and Diagnostics.

Insight of the application's health, to fix probleme faster.

* Monitoring: check the endpoints of web apps and other internet accessible services running
    * Uptime checks for groups or instances
    * Alert on criteria, like CPU or else
    * Create dashboard
    * Send notifications
* Logging: view logs from apps with filter.
    * Export logs to bigQuery, PubSub, Cloud Storage
* Error Reporting: tracks and groups errors. Notifies when errors are detected
* Trace: Sample the latency, report per URL statistics
* Debug: It connects your application to source code, to inspect code in production. No adding logging statements. 
    * Work best when code source is linked to. Like Cloud Source Repository, but can be another version control system (gitHub)

Forcing server to compress random data. Use for the stackdriver monitoring test
`dd if=/dev/urandom | gzip -9 >> /dev/null & `

## New module: Cloud Big Data
Take advantages of data for every company in the future.
Real time analytics or machine learning

## Cloud Big Data

### Cloud Big Data Plateform

Integrated serverless platform. We don't manage the server.

Cloud DataProc: A managed Hadoop (Map/Reduce) service. Map : parallel. Reduce: Final result set based on the all the intermediate results.
* Apache Hadoop, Apache Spark, Hive, Pig... 
* Request a Hadoop cluster in 90 seconds.
* scale it up and down.
* Monitor using Stackdriver.
* Pay for the resources we need for the cluster, during its lifetime.
* price rate based on the hour, pay for the second. One minute minimum billing.
* More agile use than on-premises process.
* Use preemptible VMs if possible

### Cloud Dataflow
Great when don't know in advance the size of the dataset. Or if you don't want to manage the cluser yourself

Extract - Transform - Load. Build data pipelines.
Don't need to manage resources.

You can define a complete flow to manage your data:
* A Source, like a BigQuery
* A set of Processors to manipulate data
* A Sink: like writing the result to Cloud Storage

Each step is elastically scaled. The service provides all services on demand.
Dynamically rebalance lagging work, there is less no to worry about hotkey

USe cases::
* general purpose ETL tool
* Data analysis tool, like fraud, financial, point of sale, segmentation analysis in retail...
* Even gaming

### BigQuery
Your data needs to run more in exploring a vast set of data, explore on massive Dataset.

No infrastructure to manage. Find meaninfull insigth. Pay as you go.

Load it from Cloud storage or Cloud Datastore, or stream it into BigQuery (100,000 rows per second)
SQL queries. 99.9 SLA

Global. But you specifiy the region where your data will be kept. EU, US, ASIA

BiqQuery separates Storage and computation, so you pay only the query when the query is running. But you still have to pay for the storage.

When the age of the Data reach 90 days, the price of storage for the data will be cut a bit.

### Cloud Pub/Sub and Cloud Datalab
Pub/sub : RealTime messaging service. 
* Simple
* Reliable
* Scalable

Decouple apps, scale indepently.

The pub: Publishers
The Sub: subscribers. 

1 publish, N Sub. Async.

At least once delivery. There is a small chance that the message is delivered more than once. Use Date to avoid this situation (like message skipping)

On demand scalability. Choose the quota. 

Good for big data like IoT. Good with DataFlow.
Works well on GCE.

Project Jupyter: a notebook for Data scientist with Python code. This is the purpose of Cloud Datalab.
Deploy a Jupyter for your data scientist. Only pay for the resources we use. No additional fee for the lab itself.

Existing packages available for stats, machine learning and so on.

## Machine learning
Solving problem without coding the solution. System improves themselves over time through repeated exposure to sample data.

Google Machine Learning service is used by Youtube, Photos, Google Mobile App and Translate.

TensorFlow is opensource software libraries, well suited for Neural Network, developed by Google Brain. GCP is an ideal place for it, as machine learning
needs lots of data and big calcul capacity.
Uses Tensor Processing Units (TPU) on your machine to improve calcul.

Each TPU provideds up 180Teraflops of performance. No upfront capital investment required.
Any type of data of any size. 

Google provides a range of machine learning API to specific purposes.

Two categories generally:
* Structured
    * Use ML for regression tasks, product diagnotic, forecasting. Cross sell, sensor diagnostics, logs metrics
* Unstructured
    * Image analytics, flagging content
    * Text analytics.

Use cases: provides in milliseconds a discount product they could like based on the social media post of the customers.

## Machine Learning API

The Cloud Vision API enables developers to understand the content of an image. 
* Sailboats, lion, eiffel tower

Finds, reads printed words in an image.
* Image catalog metadata
* Detect inappropriate content
* Image sentiment analysis.

The Speech Audio API converts audio to text.
* Recognizes over 80 languages and variants
* transcribe text of users, dictating in an app microphone
* enable command through voice detection.

The Cloud Natural API can understand text.
* syntax analysis
* breaking sentences into token
* relationships among the words
* Understand overall sentiment expressed in text.

CLoud Translation API translate an arbitrary string into a source language.

The Cloud Video Intelligence API
* identify key entities, that is nouns, within the video, and when they occur
* Make video content searchable and discoverable