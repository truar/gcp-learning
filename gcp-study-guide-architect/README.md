# Designing and planning a cloud solution architecture
##  Designing a solution infrastructure that meets business requirements. Considerations include:

### Business use cases and product strategy
This is pretty basic: You are supposed to be able to design a solution based on people's need.
Do they power ? Network ? Bandwidth ? Do they have a legacy, is this a step by step migration ? What are they KPI ?
What is their current limitation, where will have the more gain of ? Are they using SQL, or will they need it ... ?

Think of every detail when designing a solution for a client. It could be a million dollar mistake if you don't plan this carefully

### Cost optimization
Use the price calculator to forecast your monthly billing. Plus there are some options possible to reduce costs:
* Preemptible VMs (reduce cost drastically): VMs is yours until Google needs it. Plus, the Vms is restarted every 24hours
* Submitted CPU usage: you have a discount when you use power you planned to use
* Discount based on monthly usage: You have discount for some threshold when consuming CPU with a machine
* Optimize with autoscaling and loadbalancer
* Avoir using public internet traffic, and inter-region. See google docs for more info

### Supporting the application design
* What do you need ? A loadBalancer for serving application hosted on compute instances ? Are they managed via GKE or Instance groups ?
* Do they have some specific based OS that requires specific compute instances ?
* What are they data storage needs ? Is this heavy read/writes ? Consistency ? SQL ? Relational ? Analytics ? Mobile ? Gaming ? ...

### Integration with external systems
To integrate with external systems, you have solutions based on Cloud VPN
* Configure a VPN connection between 2 networks (subnets must not overlap) and have them communicate across a privarte secured connection
    * HA VPN is also possible (if 1 fail, the other will continue to make the network work)
* Use the external IP addresses, but this is not recommended at all (more expensive (networks cost) and less secure (data over public Internet))

Use Anthos to have an hybrid cluster based on kubernetes
* Container both on cloud and on-premises instances
* UI to manage cluster

### Movement of data
Data transfer is a real challenge when migrating to the cloud. You have different solutions to fit your needs:
* online transfer with gsutil or json API for low volume, less than 1TB
* For more, or fore moving data from another cloud provider: Storage Transfer Service
* For low bandwidth, or too large dataset: use the Transfer appliances
* Last one: BigQuery transfer service for direct usage by analytics team
 
### Design decision trade-offs
There is some functionality or requirements that you will never be able to meet, for instance:
* Strong consistency in a heavy writes/reads environments (BigTable)
* Managed systems versus specific OS needs
* Timing can also be critical for a business. What requirements are the most critical, what tradeoffs am I doing to enhance the project now ?
It is the job of the architect to know those constraints, and find the best design to fit the customer needs

### Build, buy, or modify
Consider trade-off: Good (Build) / Inexpensive (Modify) / Fast (Buy)

### Success measurements (e.g., key performance indicators [KPI], return on investment [ROI], metrics)
What does success look like ? A success for one project doesn't necessarily have the same meaning for another project.
* Is it durability of data ? Latency of the applications ? Throughput ? The number of game players ?
* And on what quantity ? what is the acceptable limit of your system ? 
* What is the answer to this question: My project is a success if ... 

### Compliance and observability
* Do you have any audit requirements, like in banking system ?
* Or if you are in the health area, what levels of compliance do you have to meet? What are the regulations of your field ? PII ? HIPAA ?

## Designing a solution infrastructure that meets technical requirements. Considerations include:

### High availability and failover design
Your design needs to be (most of the time)
* Highly available: Identify the bottleneck, the SPOF, what kind of risks do you have.
    * for instance, when configuring cloud VPN, if you have only one VPN and it fails, what will happen ? How much money do you lose
    the time for the VPN to be up again ? How much does it cost to have a HA VPN, in this emergency case ?
    * It can also recover from a data loss incident, what are your scenarios for such a problem ?
* Failover design: what kind of failure is your project sensitive ? Correlated failures ? Cascade failures ? Queries of death ?
    * You need to design to avoid this kind of issues. Here are some possible solution
        * Circuit breaker with health check to let the time to your system to get back up again, and then gradually sending the request
        * Fast start
        * Lazy deletion
        * Software retry design (to avoid overload on startup
        * Monitoring with alerts to react quickly
        * Microservices system to avoid some kind of failures
### Elasticity of cloud resources
* How do you want your solutions to behave when under attack ? when under very low traffic ? when busy ?
### Scalability to meet growth requirements
* When subject to heavy load, how your system will react ? 
    * Consider using managed instance groups, GKE, App engine or Cloud Runs/Functions
    * Failover Database to meet the need, replicas
    
For both points, consider LoadBalancer + autoscaling to meet elasticy and scalability

### Performance and latency
* If your users are located across the world, reduce latency with Cloud CDN to have your static content available quickly to user
* Consider deploying to a new region, closer to your new users, this will also reduce latency
* For performance, is your VM properly sized ? Is your software efficient ? Does it start qucikly ?

## Designing network, storage, and compute resources. Considerations include:

### Integration with on-premises/multi-cloud environments
* Configure a Cloud VPN to enable communication across multiple networks without going over the public internet
* Anthos system is great to enable containerization and API system in hybrid Cloud solutions.

### Cloud-native networking (VPC, peering, firewalls, container networking)
* Virtual Private Cloud is a network you can create to network your application given your topology.
    * Is composed of subnets (one per region for the default VPC network)
    * You can communicate using internal IP address in the same network, even across different region
    * Automatic networks create as many subnets as region available (even new not existing yet will be added)
* Firewall allows or block ingress or egress traffic coming through your network (in or out)
    * Use network tags to easily allow for group of instances (for example web-server, or database)
* VPC peering can connect two networks together, so that they communicate using the internal IP address
    * Uses the RFC 1918
    * Subnets can't overlap
    * Is great to make different projects or even organization communicate
    * The administration is maintained by each project
* Shared VPC allows connecting VPC within the same organization
    * The administration and security are centralized and manage by the VPC admin
* Use Global HTTP/HTTPS, TCP, internal load balancer to make your application with each other
    * Combine with health check
    * Have one IP to access multiple instances, or containers

### Choosing data processing technologies
* PubSub: Pub/SUb queue message highly available to send messages to subscribers
* DataProc: Create your own Apache Hadoop cluster in 90 seconds.
    * Good if you want more control on your server
    * Fully managed service
* DataFlow: execute a variety of data processing steps, in a fully distributed and managed system
* DataPrep: Prepare your data (unstructured, structured) and get recommendation on how it is best to parse your data
    * The prepared data can then be easily injected and interpreted by your Cloud DataFlow or DataProc system
* BigQuery: DataWarehouse to run massive analytics query on teraBytes and petabytes of data

### Choosing appropriate storage types (e.g., object, file, RDBMS, NoSQL, NewSQL)
* Cloud storage: Store object (files) into a bucket. 
    * Unique name across GCP
    * Be careful with security and compliance
    * Multi regional or regional, Nealine, coldline or achive
* Cloud filesystem: a filesystel pluggable into a compute engine
* Cloud SQL: RDBMS (not scale very well) for SQL and relational Data. Strong consistency
    * Web site
* Cloud Spanner: like SQL, but scale horizontally. Strong consistency
* Cloud Firestore: NoSQL Database for mobile or gaming apps. Strong consistency
* Cloud BigTable: NoSQL Database for heavy read/writes. Eventual consistency

### Choosing compute resources (e.g., preemptible, custom machine type, specialized workload)
* Compute engine is the basic resource you can get on GCP
    * Install an OS, and then do whatever you want with it
    * Preemptible reduces the cost, but the VM stops every 24hours, and get be unavailable is resources are needed by Google
    * Choose a classic OS, or use your own, or a custom one
    * Build image from snapshot
    * Select either a predefined machine type, or choose more CPU, or more RAM, given your workload
        * Google gives recommendation if the machine is overkill comparing to what you really need
    * Configure network, disk
    * Use a local disk, for fast access, but no durability (is emptied after an instance restart)
    * Add more disks (SSD or HDD given your need, prices change)
    * Disks use the network, as they are not attached to VM (except for local SSD)
    * Number of disk depends on your number of core
    * Configure snapshot, scheduled snapshot, create image from it
    
### Mapping compute needs to platform products
* Scalability: Autoscaling of Managed Instance groups or GKE
* Control: Compute engine if need more control over the system
* Capacity: Storage solution, latency, speed required

## Creating a migration plan (i.e., documents and architectural diagrams). Considerations include:

### Integrating solution with existing systems
Think of the constraints you could face:
* Can it run in parallel ? 
* Can you have a failover on the cloud ?
* Is it all or nothing ? 
* Can you link the network together using Cloud VPN ?
* What is the part of the migration that will make the most of the cloud, with a minimum cost ?

Anthos, Cloud VPN, 
### Migrating systems and data to support the solution
How much data to synchronize ? Is it in both directions ? What is the source of truth ? How will it be synchronized ?
* Data Transfer solution
    * Gsutil (bucket) or REST API
    * Transfer service ?
    * Transfer appliance ?
    
### Licensing mapping
* Do you have licensed software that needs to migrate to cloud with your systems ?
* Is it compatible ? How much the licence cost ?

### Network planning
* Will your current infra be connected to GCP ?
* How big and frequent are the communication with the cloud ?
* Does it need to specially secured ?
* Traffic over internet with Google has a cost. Can you design a VPN, or using a Google solution like
    * Dedicated interconnect
    * Partner interconnect
    * Direct peering 
    * Carrier peering
    
### Testing and proof of concept
* You can have a testing phase by having a small environment for your migrations
* Also, testing is about what you deliver to your customer ?
    * A/B Testing to start a new feature, and have only some users testing it
* How will you divide the audience ? Randomly ? By country ? Phase ? 

### Dependency management planning
* What are the dependencies in your system ? What relies on what ?
* What is the most secured part to migrate ? 
* If one part is down, how will the rest of the system affected ?

## Envisioning future solution improvements. Considerations include:

### Cloud and technology improvements
* On new features, or improvements, when will the application embraces the new changes ?
    * What is the best timing ? How would you do it ? 
    * Progressively, all in one ? A year later ?
    
### Business needs evolution
* When will your business evolves ? How to evolve the architecture to answer your new needs ?
* Is it by adding new services, or changing existing ones ? 
* Think that time is critical in business change. You have to be very fast to keep the business going.
    * Not evolving could be your $1 million mistake
    
### Evangelism and advocacy
* Who are people in charge and how do you convince them ?
    * Managed services, low overhead, high customization
    * Great performance
    * CI/CD approach
* What do they need to do their jobs the right way ?

# Managing and provisioning a solution Infrastructure

## Configuring network topologies. Considerations include:

### Extending to on-premises (hybrid networking)
* Anthos: For gradually migrating your containers from on-premises to GCP
* Cloud VPN, for regular communication (not too much data, and a correct speed limit)
* Cloud Interconnect solutions are another way
    * Dedicated/Partner interconnect (layer 2, connect to google network with your own fiber cable)
    * Direct/Carrier peering (direct access to google's servers, like youtube)
### Extending to a multi-cloud environment that may include GCP to GCP communication
* Shared VPC is great for VPC across multiple projects inside the same organization
* VPC Peering is great for hybrid networking with other Cloud provider, like AWS
### Security and data protection
* Security is a shared responsability between Google and the customer
    * For every service you use with Google, they make their part in term of security
        * Disk encryption
        * Network encryption
        * Secured OS
        * ...
        * Security at wire
    * But you are responsible for what you own
        * Your application
        * The data access with user restrictions
* In terms of data protection, the responsability are also shared
    * HIPAA: ask for a Business Associate Agreement
    * PII: protect the Personal Identifiable Information
    * GDPR: what data can you collect
    * Those compliances can not be met only by Google, but you also have to do your pars
        * Restricting access only to correct users
        * Avoid any leak
        * Reproduce test environment with Anonymized Data  
        
## Configuring individual storage systems. Considerations include:

### Data storage allocation
* Local Disk: Fast access, no persistence
* HDD: persistent, cheaper than SSD
* SSD: persistent, more expensive than HDD
* Ask for more RAM when creating the machine
* Cloud Storage for object
* Cloud SQL, Spanner
* BigTable, Firestore
* InMemory
* Filestore
* BigQuery
### Data processing/compute provisioning
* Use managed services powered by Google
    * DataProc: own cluster hadoop. More control
    * DataFlow: flow of processors to manage data
    * DataPrep: Flow of data preparation, to be consumed by DataFlow
    * BigQuery
* Or create compute instance tailored given your needs
    * Ask for more CPU, or RAM, or both
    * Choose TPU if needed
### Security and access management
* Restricts access using Service account following the principle of least privilege
* Use IAM roles
    * Primitive roles: Owner > Editor > Viewer (To be avoided)
    * Predefined roles: Set of roles to accomplish certain tasks
        * Based on permissions
    * Custom roles: to fit your needs
        * Based on same permission as Predefined
    * Create groups, and affect users to a group, easier to manage later (add, remove people from a group)
        * Group policy if possible then
* Security is a shared responsability
    * You are in charge of securing your application, data access
    * Set appropriate roles to your users, or services
    * CSEK (Customer Supplied Encryption Key)
* Use Cloud-Aware proxy Identity to restrict access to application given a user

### Network configuration for data transfer and latency
For Datatransfer:
* GSutil: must have a project and a bucket created
    * No minimum size or bandwidth required, but the transfer can be very long, if files are TB
    * < 1TB for on-premises
* Transfer service: minimum of 300Mb/s bandwidth
    * For > 1TB and other cloud provider transfer
* PB bytes of data: Transfer appliance

Latency:
* For a user, think of his geographic position: close to your regions ? 
    * Global load balancer
    * Choose region closer to the users
* Cloud CDN to deliver static content and reduce latency (best solution to reduce latency by the way)

### Data retention and data life cycle management
With Cloud Storage you can store binary files.
* Enable the versioning to avoid deletion
    * By bucket
    * By default, versioning is disable, objects are unique, and immutable
    * If you upload an existing file, it is overriden without copy or backup (if none configured)
* Data retention: when do you want to move to another class, or delete your objects ?
    * Regular (multi/region or single region) : Availability
    * Nearline: access less than once a month
    * Coldline: access less than once a quarter
    * Archive: Access less than one a year
    * The storage price decreases and the access price increases for each class above
    * Choose to change a class storage given the file size
    * choose how many versions you want to keep of each file
    
### Data growth management
* What will be the factor of data growth ?
    * Number of users ?
    * Daily usage where you keep creating and uploading files ?
* How the system will react to that ? 
    * Did you think about the storage price ?
    * What part could break because of data growth

## Configuring compute systems. Considerations include:

### Compute system provisioning
* Compute engines is the minimal service provided by Google
    * Create your own Virtual machines
    * Set information, like
        * Name an region/zone
        * CPU / RAM
        * Disk (SSD, HDD), local ?
        * Startup-script
        * Network configuration (subnet, external/internal IP)
* Group them to manage them with a Managed Instance Group
    * Create a template to have the same VM
    * Enjoy autoscaling, auto-restart
    * rolling update is also possible
    * Health check with Load Balancing
    * Metrics for instance groups with StackDriver 
### Compute volatility configuration (preemptible vs. standard)
* Preemptible is for reducing the cost of your compute resources
    * A VM is up for 24h, after it is automatically stopped
    * Google can request the resources of your VM, so don't rely on this VM for your business strategy
    * Use it in a batch processing app, where this VM could decrease the time required for the batch, but not put it in jeopardy
    * No SLA
* Standard is for regular VM, but you can still get discount:
    * committed usage: have a minimum usage of your VM, and you get a discount on it
    * Sustained: at 50%, 75% and 90%, you get discount if you use the VM for a long period
    
### Network configuration for compute nodes
* VM can communicate with each other
    * using the internal IP
        * Without configuration if they are in the same VPC
            * Even across different subnets
        * with 2 distinct VPC
            * With Cloud VPN
            * With VPC peering
            * With shared VPC
    * Using external IP address (if the VM has one)
* Firewall rules always need to be configured

* For security, design a bastion host, to avoid access to your other VMs
* Load balancer to access your VM
### Infrastructure provisioning technology configuration (e.g. Chef/Puppet/Ansible/Terraform/Deployment Manager)
The only way to reproduce an environment the exact same way (which gives you testing, regression detection possibilities), use the 
deployment manager to configure your project with IaC (Infrastructure as a code)
* Use Deployment Manager, Terraform (recommended because skills are portable)
    * Also Chef, Puppet and Ansible if needed, or if in your team skills, or company policy
* Create many similar project (for testing purpose)
    * Or stress test
* Use the deployment manager to deploy certified solution, like Jenkins, or Confluence...
    * Very easy and fast
    * Price quickly accessible
### Container orchestration with Kubernetes
* To use kubernetes to run your application and podes, you can create a GKE cluster
    * Create the physical nodes (compute instances) on which your PODS will run
    * Use `kubectl` CLI to manage your cluster 
```
gcloud container clusters get-credentials echo-cluster --zone=us-central1-a
kubectl create deployment echo-web --image=gcr.io/qwiklabs-resources/echo-app:v1
# Creates a LoadBalancer in your GCP project to expose your pod over the public internet
kubectl expose deployment echo-web --type=LoadBalancer --port 80 --target-port 8000
kubectl set image deployments/echo-web echo-app=gcr.io/qwiklabs-gcp-00-708c300b3c57/echo-app:v2
kubectl scale deployments/echo-web --replicas=2
```
* Kubernetes names:
    * A POD is a single unit of deployment
    * Namespace logically groups PODS together
    * Service exposes a POD (given the exposure type)
    * Replicas replicate the POD in the environment, across the WorkerNode
    * WorkerNode are compute engine instances (if using GKE)
* There are different kinds of exposure:
    * LoadBalancer: Creates a LoadBalancer (with GKE a HTTP load balancer) and expose the POD to the outside
    * ClusterIP: Cluster not available outside of the container. Internal communication only
    * NodePort: Exposes each Node outside the cluster. Access is <NodeIp>:<NodePort>
    * ExternalName: Exposes using a DNS
    * Ingress: routing users given a path (HTTP/S route for instance)
   
   
* With regional GKE cluster, the master is replicated, so no downtime for a migration
    * With Zonal Cluster, a downtime is possible
* Master can updated
    * Automatically by Google
    * Or you can do it yourself
```
gcloud container get-server-config
gcloud container clusters upgrade $CLUSTER_NAME --master
gcloud container clusters upgrade $CLUSTER_NAME
```

* To resize a Node Pool (gcloud comand)
```
gcloud container clusters resize $CLUSTER_NAME --node-pool $POOL_NAME --size $SIZE
# To drain the nodes before removal
gcloud beta container clusters resize $CLUSTER_NAME --node-pool $POOL_NAME --size $SIZE
```
* Cluster autoscaling
```
gcloud container clusters create $CLUSTER_NAME \
    --num-nodes $NUM \
    --enable-autoscaling \
    --min-nodes $MIN_NODES \
    --max-nodes $MAX_NODES \
    --zone $COMPUTE_ZONE
```
* Master IP rotation
```
gcloud container clusters update $CLUSTER_NAME--start-ip-rotation
```
* IAM roles are used to manage cluster access
* Kubernetes uses RBAC (Roles based access control)
    * Restrict access to resources inside the cluster  
* For storage use GCP services (recommended)
    * Or expose database in a container, and create/use volume to persist data
* NodePools are used to group node with the same configuration together
* Pay only for nodes, not PODS. (and not for the master)

* Have features like
    * auto-scaling (to scale your compute engine instances)
    * Auto-restart (in case of failure)
    * auto-repair (to fix a broken node)
    
# Designing for security and compliance
## Designing for security. Considerations include:

### Identity and access management (IAM)
IAM: Identity Access Management:
* Who can access what resources ?
    * Who: a person or a service account (email)
    * Can access: Set of roles
        * Primitive roles: Owner > Editor > Viewer
        * Predefined roles: set of permissions to allow an action on a resources
        * Custom roles: define your own roles by aggregating permissions together, given your business needs
* Use groups as a best practice
* follow the "Least privilege principle": a person or service should be given the minimal set of rights to perform is daily job
 
### Resource hierarchy (organizations, folders, projects)
* Organization and folder are only applicable in a company, they are optional
* Resources are grouped by projects
* Projects can be grouped into folders
* Folders can be grouped into folders
* Folders belong to an organization Node
* What has been given by a upper node can be taken away
    * You can apply roles to person (or service) at a specific folder or organization
    * But you can't restrict the access at a lower level
    * An "Owner" at the organization node will be owner of every project, even if configured differently at the project level
    
### Data security (key management, encryption)
* Encryption is at the heart of every service provided by Google
    * at rest
    * AES 256 symmetric key
    * Keys are encrypted by the KEY (Key Encryption Key)
* Key are automatically rotated to ensure a maximum of security
* You can define your own periodicy: CMEK
    * Customer Managed Encyrption Key
    * Key created by google, but you have more control over the default key
* You can provide your own key: CSEK
    * Customer Supplied Encryption Key
    * But you need to perform yourself the rotation
    * Key created in your environment

### Penetration testing
* You can perform your own penetration testing, without telling google.
* You are independant if you test only your resources
* When you do so, be very accurate and shape the scopes of the test

### Separation of duties (SoD)
* Who is responsible of key rotation ? This is not the same as the one who can create them ?
* Have a backup who can rotate the key if the primary one is not available
* Create service account only for services, and regular account for regular people
* Who can affect new roles ? At the organization node / Folder / projects ? 

### Security controls (e.g., auditing, VPC Service Controls, organization policy)
* How to monitor security ? What logs are available ?
* Stackdriver keeps a lot of access logs, this could be a great way to monitor access
    * Define alert based on access log, check for many forbidden access to detect a potential attack
* Organization policy: use PenTest to build a matrice of responsabilities, and see who has access to what resources ?

### Managing customer-managed encryption keys with Cloud KMS
* You can define your own periodicy: CMEK
    * Customer Managed Encyrption Key
    * Key created by google, but you have more control over the default key
    * Key management, key rotation, standards and policy compliance

## Designing for compliance. Considerations include:

### Legislation (e.g., health record privacy, children’s privacy, data privacy, and ownership)
HIPAA:
* No certification reconginzed by the US HSS for HIPAA compliance
* Shared responsabilities between Google and the customer
* Google is audited every year for certains certification, like:
    * SSAE16 / ISAE 3402
    * ISO 27001
    * ISO 27017: Cloud Security
    * ISO 27018: Cloud Privacy. Standard of practice for protection of personal identifiable information (PII)
    * FedRAMP ATO
    * PCI DSS v3.2
* Customer responsabilities:
    * Making sure the application they build on top of GCP is HIPAA compliance
        * Security, data access, Roles, authentication
    * Require a Business Associate Agreement from your account manager
        * Not all GCP features are HIPAA compliance. Make sure your do not use such feature
        or disable them if you don't need them
    * For a full list of services, see: https://cloud.google.com/security/compliance/hipaa
    * Plus, there is a list of best practices, like:
        * Configure and use properly the IAM roles
        * do not cache in CDN PHI information
        * Avoid using PHI information in any part of the process (build, deployment, run)
GDPR: 
* Google ensures, like usually, many things at rest of its system
    * Security experts, lawyer 
    * Confidentiality training for the employee with a confidentiality agreement
    * Make sure third part they are using are compliant too
* As a customer, you have to
    * Familiarize yourself with the provisions of the GDPR
    * Create an updated inventory of personal data that you handle. You can use some of our tools to help identify and classify data.
    * Review your current controls, policies, and processes for managing and protecting data with the GDPR’s requirements. Find the gaps and create a plan to address them.
    * Consider how you can leverage the existing data protection features on Google Cloud as part of your own regulatory compliance framework. Review G Suite or Google Cloud Platform’s third-party audit and certification materials to begin.
    * Review and accept our updated data processing terms via the opt in process described here for the G Suite Data Processing Amendment and here for the GCP Data Processing and Security Terms.
     
### Commercial (e.g., sensitive data such as credit card information handling, personally identifiable information [PII])
PII:
* Protect sensitive data using the Cloud Data Loss prevention API
* 
### Industry certifications (e.g., SOC 2)
* ...
### Audits (including logs)
* Use the stackdriver suite to get the access logs.
* Require an audit
* Protect your application

# Analyzing and optimizing technical and business processes
## Analyzing and defining technical processes. Considerations include:

### Software development life cycle plan (SDLC)
* Choose the right to enhance your softwate development team, and use the best of GCP
* Cloud Source Repositories is very handy when using the profiler to audit on production your code, and detect potential bugs
    * Combine it with some other solutions, like GitHub, GitLab or others solutions
    * Google will keep the repo in sync
* Cloud Container Registry: To store your docker image in your project
* Cloud Build / Cloud Trigger: To build image on GCP
* Deployment manager: To automatically deploy solution, like complete project, or part of your application

### Continuous integration / continuous deployment
* To build a Continuous Integration
    * Use Source Repositories, Cloud Build and Cloud Trigger to create your image as soon as new code is pushed  
    * Use Cloud Build to build an image out of your code
        * It is like doing Docker build for instance, but it is directly on your Google Container Registry
    * Combine with Cloud Trigger to start a build each time a push is made on a branch, or on every branch
* To have a Continuous Delivery process
    * Use a third part software, like spinnaker, or Jenkins
### Troubleshooting / post mortem analysis culture
* Don't look to blame someone. Instead, use this as a way to improve your system in its globality
* Conduct Post-mortem analysis with your team, and focus on finding the root cause of this
* Make sure the problem won't ever happen again

### Testing and validation
* Testing is a required process to validate your application before the production
* Testing cost money, but how much is a regression in your system ? Can you afford it ? What is the impact on your customer if so ?
* Use the Deployment manager to deploy a testing environment which is a mirror of your production
    * Ensure you run stress test, nominal cases and anything you judge necessary to validate your version
* Create a pipeline to deploy everything automatically, and releases become just another automated part in your deployment, no longer a charge
* Ensure everythings is "green" before sending it to production 

### Service catalog and provisioning
* Use the Deployment Manager and the Marketplace to deploy fast certified application to your system
    * A blog with wordpress
    * Jenkins for automated pipeline
    * ...
* Create your own template file to deploy your infrastructure quickly the same way 
### Business continuity and disaster recovery
* Make a disaster plan
* Plan for exercice to make sure your process is validated and can actually perform a rollback
* Identify the elements that are covered by a potential disaster (natural, bad actions, server down) and how your system have to react to it
    * Cold backup: just a backup file you play. Usually, system is up in a hour
    * Warm backup: system up in minutes
    * Hot backup : no downtime (or barely seconds)

## Analyzing and defining business processes. Considerations include:

### Stakeholder management (e.g. influencing and facilitation)
* Identify the person in your company that have access to some cloud based decisions. 
    * What are their roles ? Business ? Technique ? Architect ?
    * What solutions can you find that will allow them to do their jobs ? Datascientist for ML ? Engineer for deploying apps ?
### Change management
* Quality is a process, not a product. 
* What can you do to enable a change culture in the company.
    * From going to on-premises with rigid process to Cloud with more agile process ?
* What would be the cons from migrating or just using the Cloud ? 
### Team assessment / skills readiness
* Team training is a big part of a Cloud Architect
    * Having the team ready in case of emergency
    * Emergency situation test to repeat the process
* How will you make your team ready for such situation ?
    * What skills do you need to practice ?
    * Reactivity ? Process ? Calm under pressure ?
### Decision-making process
* How long do you need to make a decision ? 
* Do yo you have a minimal time you can't reduce ?
* In case of unexpected situation, how fast can you react ? Depending on what ?
    * The situation ?
    * Your skills ?
    * Your infrastructure
### Customer success management
* What can you measure to ensure the success of your product ?
   * Latency for customer to get a fast access ?
   * Throughput to deal with many customers at the same time
   * Durability to keep customer data
   * Availability to have your application always accessible
* What metrics applies the best to yout product ?
    * Video game: number of players
    * Financial: Number of transactions ?
    * WebSite: Number of unique visitor ?
* How do you know what time is the best to get a v2, or improve the existing application
    * And what to improve first ?
### Cost optimization / resource optimization (capex / opex)
* Migrating to the cloud will make you have operation expenditures instead of Capital expenditure
    * You no longer pay for big machine upfront
    * Pay for what you need, and get a billing issue at the end of the month
* Gain in flexiblity by starting more VMs if needed, or reduce the compute power if you no longer need it
* What gain do you want to make ? What are your financial goals ?

## Developing procedures to ensure resilience of solution in production (e.g., chaos engineering)
To ensure the liveness of your application, you need to define disaster recovery scenario in case of a system failure.
Did you identify everything that could cause your system to collapse ? How do you plan to make your application work in case of partial failure ?
* Cascading failure, Correlated failure, SPOF, Queries of death, positivie feedback failure (retries)
* Circuit breaker pattern, SPOF: N + 2 machine, Health checks, Divide business logic, make system independant

Prepare your team for such a scenario. Create a spare environment in which you can practice your active recovery skill

Techniques:
* Obviation: Design a systelm where a specific error can not occur
* Prevention: Take steps to ensure a problem will not occur
* Detection and migration: Detect a failure before or as it is happening, with alerts based on metrics. Take steps to reduce the effect
* Graceful degradation: Reduce your system to limit the risk and the spread of the problem. Fix it, and go back to normal work
* Repair: Fix a problem, it won't happen again
* Recover: Plan your system to recover when such an error occured (easy button strategy)

# Managing implementation
## Advising development/operation team(s) to ensure successful deployment of the solution. Considerations include:

### Application development
* GKE, GCE, App Engine, Cloud Run, Cloud Function, Containers

### API best practices
* Cloud SDK is a great tool to interact with Google API
* For more automated system, use REST API to interact with Google
* Cloud ML has some features available for Machine Learning
    * Cloud Vision API, Cloud speech to text, Cloud text to speech, Cloud Translation API, Cloud Natural language API, Cloud Visio Intelligence API, DialogFlow Enterprise Edition
    
### Testing frameworks (load/unit/integration)
* Different kind of test:
    * Black box: Test a system from a user perspective who doesn't know how it works. Focus on user experiences
    * White box : Use your knowledge to work on inner part. Improce performance
    * Unit
    * Integration
    
### Data and system migration tooling
* Cloud Transfer Service (for on-premises to cloud migration), gsutil (for service on cloud), Cloud Transfer appliance (for massive data)

## Interacting with Google Cloud using GCP SDK (gcloud, gsutil, and bq). Considerations include:

### Local installation
* Install the SDK on your system, very easy, depends on the system you're using
### Google Cloud Shell
* Use Cloud shell that stores up to 5GB of your home dir
    * Connect to a compute engine automatically
    * Very easy, you have your account connected by default
    * Easy to simulate a service account

# Ensuring solution and operations reliability
## Monitoring/logging/profiling/alerting solution
* Stackdriver suite is great to monitor your application
    * Logging: Get the log of your application, but also security log, audits logs, data access logs, and ensure your data are safe
    * Trace: Know what are your latency point, what request take most of the time
    * Error: Connect to the error of your system (can also be done with logging)
    * Debugger: Take snapshot of your code and debug without end user impact
    * Monitor: Create your dashboard to keep track of your application metrics evolution
        * Create alert to receive a notification when an action is required
        * Send notification like email, pubSub or more
        * Create uptimeChecks to ensure the liveness of your product
    * Profiler: Profile your code to know what part takes most of the time
    
## Deployment and release management
* A/B testing: make subpart of user testing new features, and collect early feedback
* Canary deployment: Migrate to your new version steps after steps
* Green/Blue deployment: Create a blue deployment, and once ready, migrate the green to the blue
* Rolling update
* Rollback in case of error

## Assisting with the support of solutions in operation
Use GCP tools to control and reduce risk of your system while working.
* Health check to make sure system is up and running
* LoadBalancer to ensure service access from the outside world
* GKE, GCE, App engine for solution in production
* Logging access with stackdriver
* Cloud deployment Manager to reproduce environment

## Evaluating quality control measures
What measures do you have to ensure quality of the system ? 
* What are you monitoring and why ?
* Is it latency, to make sure the user get a request fast
* Do you want to know how long a system responded after it received the last packet
* Is it security control, which you can view in log access
