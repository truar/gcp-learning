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
### Data processing/compute provisioning
### Security and access management
### Network configuration for data transfer and latency
### Data retention and data life cycle management
### Data growth management

## Configuring compute systems. Considerations include:

### Compute system provisioning
### Compute volatility configuration (preemptible vs. standard)
### Network configuration for compute nodes
### Infrastructure provisioning technology configuration (e.g. Chef/Puppet/Ansible/Terraform/Deployment Manager)
### Container orchestration with Kubernetes

# Designing for security and compliance
## Designing for security. Considerations include:

### Identity and access management (IAM)
### Resource hierarchy (organizations, folders, projects)
### Data security (key management, encryption)
### Penetration testing
### Separation of duties (SoD)
### Security controls (e.g., auditing, VPC Service Controls, organization policy)
### Managing customer-managed encryption keys with Cloud KMS

## Designing for compliance. Considerations include:

### Legislation (e.g., health record privacy, children’s privacy, data privacy, and ownership)
### Commercial (e.g., sensitive data such as credit card information handling, personally identifiable information [PII])
### Industry certifications (e.g., SOC 2)
### Audits (including logs)

# Analyzing and optimizing technical and business processes
## Analyzing and defining technical processes. Considerations include:

### Software development life cycle plan (SDLC)
### Continuous integration / continuous deployment
### Troubleshooting / post mortem analysis culture
### Testing and validation
### Service catalog and provisioning
### Business continuity and disaster recovery

## Analyzing and defining business processes. Considerations include:

### Stakeholder management (e.g. influencing and facilitation)
### Change management
### Team assessment / skills readiness
### Decision-making process
### Customer success management
### Cost optimization / resource optimization (capex / opex)

## Developing procedures to ensure resilience of solution in production (e.g., chaos engineering)

# Managing implementation
## Advising development/operation team(s) to ensure successful deployment of the solution. Considerations include:

### Application development
### API best practices
### Testing frameworks (load/unit/integration)
### Data and system migration tooling

## Interacting with Google Cloud using GCP SDK (gcloud, gsutil, and bq). Considerations include:

### Local installation
### Google Cloud Shell

# Ensuring solution and operations reliability
## Monitoring/logging/profiling/alerting solution

## Deployment and release management

## Assisting with the support of solutions in operation

## Evaluating quality control measures