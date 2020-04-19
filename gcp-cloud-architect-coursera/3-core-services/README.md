# Core Services

## Cloud IAM
Cloud Identity and Access Management.
Based on email address as unique user mail.

Who Can do what On which resources

* `Who`: Could be a person, or a group, or an application
* `Can do what`: specific privileges or action.
* `On which resources`: Any GCP resources

* Organisation node
    * The company. Inherited by all resources under the organization
* Folder
    * A department. Inherited by children
    * Cannot restrict access granted at the parent level
* Project
    * Cannot restrict access granted at the parent level
* Resources
    * Have exactly one parent
    * Cannot restrict access granted at the parent level

Policy can be set at each level. Contains a set of roles and a role member

## Organization node
Root node, but not mandatory. But it can't folder without Organization

This node has specific role, like the Organization admin. With this role, you can administer all resources belonging 
to the organization, useful for auditing.

Also exists the Project creator role, which allows users to create project.

The organization node is created when a G-Suite or cloud identity account creates a GCP project.
There is 2 key roles, assigned to different users/groups for managing the Organization node:
* G-suite or Cloud Identity super admin:
    * Assign organization admin role to some users
    * be the point of contact in case of recovery issues
    * Control the lifecycle of the GSuite or Cloud Identity account and Organization resource
* Organization admin:
    * define IAM policies
    * Determine the structure of the resource hierarchy
    * Delegate responsibility over critical components such as Networking, Billing and Resources Hierarchy through IAM Roles
    * Following least privilege responsibility principles, you can only create folders with this role 
    
Folders:
* Suborganization within the organization
* Isolation boundary between projects.
* Model different departments, services, teams.
* Grant the head of department the full ownership over their department (i.e folder)
* Users in one department can only create and access resources in their department

Resource manager roles:
* Organization
    * Admin: Full control over all resources
    * Viewer: View access to all resources
* Folder
    * Admin: Full control over folders
    * Creator: Browse hierarchy and create folders
    * Viewer: View folders and projects below a resource
* Project
    * Creator: Create new project (automatic owner) and migrate new projects into organization
    * Deleter: Delete projects
    
   
## Roles
3 types of roles:
* Primitive: available in GCP console. Broad (affect all resources in that project). Fixed, coarse-grained level of access
    * Owner: invite members, remove members, delete projects and also editor
    * Editor: deploy applications, modify code, configure services and also viewer
    * Viewer: Read-only access
    * billing Administrator
        * Manage billing
        * Add and remove administrators
        * Can't change resources in that project
              
Roles are concentric: Owner includes editor, editor includes viewer.
Projects can have multiple owners, editors, viewers

Predefined Roles:
* prevents unwanted access to other resources
* granular access to GCP resources
* Collection of permissions
    * To do a meaningful operations on a resource, you need multiple permissions.
    
Compute engine has predefined IAM roles:
* Compute Admin: Full control of all Compute Engine resources (compute.*)
* Network Admin: Permission to create, modify and delete networking resources, except for firewall rules and SSL certificates
    * Allows read-only to firewall and SSL certificates and instances to view the their ephemeral IP
* Storage Admin: Permissions to create, modify and delete disks, images and snapshots
    * Only for people managing storing

Roles: Abstract functions and are customized to align with real jobs.

But if it is not enough, we can create custom roles. Assign a set of permissions to a custom role, and keep in mind
to apply the *least privilege*.
* Example: Role to start and stop Virtual machine, but not reconfiguring them
* Not maintained by Google. If there is new permissions, they will not be taken into account

## Members
5 different types:
* Google accounts
    * A developer, or an admin
    * Any email associated with a GCP account, a Gmail or another domain, can be an identity
* Service accounts
    * Belongs to an application. Run code hosted on GCP, specify the account that runs it.
    * Can create as many as we need
* Google groups
    * Name collection of google account or services. convenient way to apply access policy to a group of users
    * Every group has a unique email address
* G Suite domain
    * Organizations internet domain name
    * add a user to a G-Suite -> Automatically creates a google account
* Cloud identity domain
    * Manage users that are not part of the G-suite
    * Get the same capabilities for GCP
    * But are not part of Gmail and any other tools
    * Free in premium edition

You can't user Cloud  IAM to manage users and groups. Instead, use Cloud identity to manage users, or G-Suite.
IAM is just to manage roles and permissions, not creating users

Google Cloud Directory Sync: If you have an existing directory solution for instance. Migrate users and groups into GCP.
* Use same usernames and password they already use
* One way only. Read only for the source directory
* Run scheduled sync. 

GCP provides a SSO Authentication.
When auth is required, Google will redirect to your system. If user authenticated, it has access to resources. Otherwise, it is asked to log in.

## Service accounts
Belongs to an application, no individual end users.
No users credentials, when communicating between application, or if your application needs to interact with GCP resources, like storage, or compute

* Identified by an email address (a bit complicated sometimes)
* Three types of service accounts
    * User created (custom)
        * More flexibility, but more managements
        * Create as many as we need
    * Built-in (provided by google)
        * Compute engine and App engine default service accounts
        * Compute engine default:
            * name has `-compute` suffix
            * Is automatically project editor
            * Used by default by all instances created using GCP console or Cloud Shell
    * Google APIs service account
        * Runs internal process on our behalf
        * Granted editor role on our project


Compute Engine default service account can be overriden at instance creation.

Scopes:
* Used to determine whether an authenticated identity is authorized.
* A has a read-only scope for buckets, B has a read-write scope for buckets
* Can be customized when creating an instance with the default service account
    * Can be changed when instance is stopped
* Access scopes are the legacy method of specifying permissions for your VM
    * Before IAM roles, they were the only way for granting permission to a service account
    * For user-created service account, use Cloud IAM roles instead

* Default service accounts support both primitive and predefined roles
* User created service accounts only use predefined IAM roles

Service accounts can also be used to grant resource to users or group of users.
The users or groups has access to all resources the service accounts has access.

Use keys to authenticate:
* GCP managed keys
    * Can't be downloaded
    * Automatic key rotation every 2 weeks
* user managed keys
    * Rotation and security is left to the user
    
## Cloud IAM best practices

Leverage and understand policy hierarchy
* Use project to group resources that share the same trust boundary
* Check the policy granted on each resource and make sure you understand the inheritance
* Use "principles of least privilege" when granting roles
* Audit policies in Cloud audit log: `setiampolicy`
* Audit membership of groups used in policies

Granting roles to groups instead of individuals
* Update group membership instead of changing Cloud IAM policy
* Audit membership of groups used in policies
* Control the ownership of the Google group used in Cloud IAM policies 

Service accounts:
* Be careful when assigning the service account user role, because it has access to all the resources the service accounts has access to
* When creating a service account, give it a display names that identifies it clearly for its purpose
* Establish a naming convention for service accounts
* Establish key rotation policies and methods
* Audit with serviceAccount.keys.list() method

Cloud identity aware Proxy (IAP)
* Central authorization layer for app accessed by HTTPS
* Enforce access control policies for applications and resources
* Identity-based access control
* Cloud IAM policy is applied after authentication

## Storage in GCP

* Object:
    * Cloud Storage:
        * Binary object
        * Images, media, serving, backups
* Relational 
    * Cloud SQL
        * WebFrameworks
        * CMS, E-commerce
    * Cloud Spanner
        * RDBMS+Scale, HA, HTAP
        * User Metadata, Ad, Finance, Marketing
* Non relational
    * Cloud firestore
        * Hierarchical mobile, web
        * User profiles, game state
    * Cloud BigTable
        * Heavy read + write, events
        * AdTech, financial, IoT
* Warehouse
    * BigQuery
        * Enterprise data warehouse
        * Analytics, dashboard
 
 
## Cloud Storage

Use cases:
* Serving website content
* Storing data for archiving and disaster recovery
* Distributing large data objects to users via download

* Scalable to exabytes
* Time to first byte in milliseconds
* Very high availability across all storage class
* Single API across storage classes
 
Is not really a file system. It is a collection of buckets you place your objects into.
* URL to access objects.

Regional:
* is cheaper than multi-regional, but less redondant
* use for frequently accessed data associated to a compute engine in the same region

Multi-regional:
* geo-redondant
* Regions are 100 miles away from each other (160km)
* Only in mutli-regional location (not all country has it)

Nearline:
* Low cost for infrequently access data. Read or modify your data less than once a 1 month.

Coldline:
* Very low cost. Disaster recovery.
* Higher retrieval cost.
* Access once a quarter
        
        
All have a "11-9's" durability
* You won't lose your data. Barely impossible


* Buckets: Globally unique name, can't be nested. A collection of objects
* Objects: No mimimum size to the object. Multimedia...
* Access: gsutil, or console. 

When uploading file to Storage, if the storage class is not specified, the object is assigned the bucket storage class.
You can change the default storage class of a bucket, but you can't change a Regional to a Multi-regional bucket, and vice-versa.

Both can be changed to coldline or nearline. Change the storage class of an object in the bucket.

Buckets and Objects access:
* Use IAM to control which individuals or groups can access the resource:
    * See, list, edit, upload...
    * For most purposes, CLoud IAM is sufficient
* Use Access Control List ACL for finer control
    * Mechainism to define who have access to buckets and objects
    * Level access to those resources
    * 100 for a bucket or an object
    * One or more entries
        * A scope: defines who can perform the specified actions, like a group or a user
            * example: allUsers (anyone), allAuthenticatedUsers (with a google account), user@mail.com
        * A permission: what actions, like read or write
        
* Signed URLS provide a cryptographic key that gives times limited access to a bucket or object
    * Grant limited time access tokens that can be used by any user (don't require an authentication by the user)
    * Create a URL that grant the read access to the resource, and specifies when access expires
    * Assigned to the private key of the service account
    * Once the URL is given, it is out of our control
* Signed Policy document
    * Determined what kind of file can be uploaded by someone with assigned URL


## Features
* Customer supplied enrcyption keys 
    * Like encryption key to encrypt an attached disk, use your own to encrypt the data in your bucket
* Lifecycle management
    * Delete or archive object automatically
* Object versioning
    * You are charged for each versions in the bucket
    * Feature to be enabled
* Directory sync (sync VM with a bucket)
* Object change notification
* Data import
* Strong consistency

Objects are immutables. An uploaded can't change during storage lifetime.
Versioning: 
* Enabled for a bucket
* can be turned on and off dynamically. 
    * The bucket stopped creating versions, but the existing versions still exists
* When uploading an object with the same name, a the previous versions is automacilly archived, with a randon number ID
* Maintains a history of modifications objects
* Older object can be restored
* !! Pay for the versioned object

Lifecycle management:
* To save money
    * Downgrade storage class of objects older than a year
    * Time to live for object
    * Archiving older versions
* Common use cases
    * delete objects created before a specific date, for example January 1st, 2017
    * Keep only the most recent version of each object in a bucket
* assign to a bucket
* set of rules applies to all of objects in the bucket
* When object meet the criteria of the rules, the action specified is executed on the object
* Inspection occurs in asynchronous batch. So rules may not be applied immediatly (24hours to apply sometimes)

Object change notification:
* Notify an app anytime when an object is changed, or uploaded, removed...
* A WebHook, that send a Web request
    * Instance: upload an image, and create a thumbnail
* But consider using Cloud Pub/Sub
    * Faster, more flexible, easier to set up, more cost effective.
    * Distributed real time messaging system

Data import services: Upload batch files, or big files:
* Transfer Appliance
    * A hardware appliance to securely migrate large volumes of data: hundreds of terabytes to one petabyte
    * No business operations disruptions
* Storage service
    * high performance import for online data
    * Another Bucket, like Amazon S3, or HTTP/S location
* Offline media import
    * third party provider that uploads data stores physical media, like USB key, HDD, flash drives...

Cloud storage provides strong global consistency
* As soon as the object is uploaded, you can download it immediatly.
    * Upload is strongly consistent => You never receive a 404
* Strong consistency for deleting object as well => You directly receive the 404 after object deletion

* Read after write
* read after metatadata update
* Read-after-delete
* Bucket listing also strongly consistent
* Bucket creation as well
* Granting access to a resource

Decision tree to know the appropriate storage class
* Less than once a year : coldline
* LEss than once a month : nearline
* More thant that : Regional or multiregional, depending on availability needs

```
gsutil acl get gs://
gsutil acl set private gs://
gsutil acl ch -u AllUSers:R gs://

gsutil lifecycle get gs://
gsutil lifecyle set life.json gs://

gsutil versioning get gs://
gsutil versioning set on gs://

student_04_2c6eb5588473@cloudshell:~ (qwiklabs-gcp-04-06079f3a1ffb)$ gsutil cp -v setup.html gs://$BUCKET_NAME_1
student_04_2c6eb5588473@cloudshell:~ (qwiklabs-gcp-04-06079f3a1ffb)$ gsutil ls -a gs://$BUCKET_NAME_1/setup.html
gs://truar-test-1/setup.html#1586950589046461
gs://truar-test-1/setup.html#1586951541292676
gs://truar-test-1/setup.html#1586951563098991

gsutil rsync -r ./firstlevel gs://$BUCKET_NAME_1/firstlevel
```

## Cloud SQL

Managed SQL service:  MySQL or PostgreSQL
* Patches and updates always applied
* We have to administer user and admin
* Supports many clients
    * `gcloud sql` 
    * App engine, G suite scripts
    * Applications and tools
        * SQL Workbench, Toad
        * External applications using standard MySQL drivers

Performance:
* High performance and scalability
* Up to 30Tb of storage capacity
* 416 Gb RAM
* Scale out with read replicas

Choice: 
* Mysql 5.6 or 5.7
* PostgreSQL 9.6 or 11.1

Other services:
* Replicate data between mutliple zones
* automated and on-demand backup, with point in time recovery
* Import and export databases using MySQL dump
* Scale out replicas, not restart or down time

Choosing the correct connection type (factor: security, performance, automation)
* If hosted within the same Region, use private IP address : faster, no trafic over the internet, more secure
* Another region or project
    * Recommended: Cloud Proxy: handles authentication, encryption and key rotation
        * If need more control, generates and manage your key yourself
    * Unencrypted connection by authorizing a specific IP Address, over external IP address
    
* If need more performance, scalability... use Spanner.
* If have really specific installation, OS... use compute Engine.

* solution to migrate from mySQL to CloudSQL

## Cloud Spanner

* Scale to PetaBytes
* Horizontal scalability. Relational database structure with no SQL horizotnal scale
* High availability.
* Inventory, financial applications
* Strong consistency

* Schema
* SQL
* Strong consitency
* High availability
* Horizontal scalability
* Automatic replication

Use cases: 
* Financial services in the retail industries
* transactions
* Inventory

How it works ?
* replicate data in n Cloud zones, even across regions 
* Database placement is configurable (choose your region)
* Replication with google fiber's network, with the atomic clock

why using spanner ? Outgrown database or sharding databse for throughput high-performance, need transactional consistency, global data and strong consistency

## Cloud firestore

* Document Database
* Simplifies storing, syncing and querying data
* Mobile Web and IoT apps at global scale
* Live synchronization and offline support
* Security features
* ACID transactions
* Multi-region replication
* Powerful query engine
    * No downtime, no degradation. Gives flexibility in the way of structuring data
    
* Cloud Firestore is the next generation of Cloud Datastore. You can create a Datastore Database, but you can't combine Datastore and Firestore in the same project
* Use Firestore improved storage layer, while keeping Cloud Datastore system behavior
* Transactions are strongly consistent (no eventually consistent like before)
* Transactions are no longer limited to 25 entity groups
* Rights to an entity group are no longer limited to one per second

Native mode
* new strongly consistent storage layer
* Document data model
* Real time updates
* mobile and web clients libraries

Guidelines: 
* Use Firestore in datastore mode for new server projects
* USe native mode for new mobile and web apps

* API compatibility

Decisions tree:
* schema might change and adaptable database, scale to 0, low maintenance overhead scaling up to terabytes -> firestore
* No transactional consistency -> Cloud BigTable

## Cloud BigTable
No transaction consistency.

* Petabytes scale
* Low latency
* Hadoop / HBase, Cloud data flow and Cloud data proc
* Ideals for AdTech, FinTech and IoT

* sorted Key Value Map
* Tables composed of Rows
* Row describes a single entity
    * Indexed by a single RowKey 
* Columns contain individual value for each row
    * Grouped in column family when they relate to each other
    * Identify by a combination of the column family and the column qualifier
* Each row column intersection can contain multiple cells, or versions at different timestamps, providing a record of how the stored data has been altered overtime
* Data are sparsed : if column is empty, it does not take up any space

* Processing is handled separately from the storage.
* a Cloud BigTable is sharded into tablets (like region for Hbase)
* Learn the access pattern, tp update the index and make sure every nodes can access it evenly.

Need to store more than one TB of data, high volumes.
Smallest Cloud BigTable cluster:
    * 30.000 Operations per second, 3 nodes. You pay for them, even if your applications is not using them
    
## MemoryStore
A Redis database

* fully managed in memory data store service
* you don't manage your redis instance and deployment, just focus on writing code
* High availability, failover, patching and monitoring
    * replicated across 2 zones for 99.9% SLA
* Sub-millisecond latency
* Instances up to 300GB
* Network throughput of 12Gbps
* Easy Lift and Shift
    * Fully compatible with the Redis protocol from OpenSource redis to Cloud InMemoryDatastore
    
    
## Quotas and Resource Management

## Cloud resource manager

* Resource monitoring goes bottom's up. Project is associated with one billing account.
* Organization contains all billing accounts

Projects accumulates the consumption of all its resources
* Track Resource and quota usage
   * Enable billing
   * Manage permissions and credentials
   * Enable services and APIs
* Projects use three identifying attributes
    * Project name -> Not use by any API
    * Project number
    * Project ID
    * Those information can be retrieved on the GCP console
    
Resource hierarchy:
* Global : like images, snapshots, networks and global resources
    * Regional: like External IP addresses
        * Zonal: Disks and instances
* All are organized into a project
* Each project has its own billing and reporting

## Quotas

* How many resources we can create per project
    * For instance: Only 5 VPC per projects
* How quickly can you make API requests in a project: rate limits
    * 5 admin actions/second for Cloud Spanner
* How many resources you can create per region
    * 24 CPUs region/project

Increase: Quotas page in Gcp Console, or support ticket

Why quotas ?
* Prevent runaway consumption in case of an error or malicious attack
* Prevent billing spikes or surprises
* Forces sizing consideration and periodic review

A region can be out of local SSDs, if that is the case, even your quota is good, you won't be able to create a new Local SSD for your instance.

## Labels and Names

* Organizing GCP resources. 
* Key/Value pair attached to resources, like disks, VM, snapshots and image
* 64 labels per resources
* Examples
    * Environment of the virtual machines
    * List instances for inventory purposes
    * Run bulk operations

Recommendation:
* Based on teams or cost center to distinguish between instances owned by different teams. Cost accounting or budgeting
    * team:marketing
    * team:research
* Distinguish between components
    * Component:redis
    * component:frontend
* Environment or stage
    * env:prod
    * env:test
* Owner or contact
    * owner: gaurav
    * contact: opm
* State
    * state: inuse
    * state: readyfordeletion

Do not mismatch labels and tags used in VPC (networking and firewall rules)

## Billing

All projects accumulated into one billing account

Bugdet: helps you controlling the cost by sending alerts
* A budget has a name and a project to be applied to
* Specific amount, or based on previous month billing
* Based on amount, you can then set alerts
    * email when 50%, 90% and 100%
    * Also cloud Pub/Sub notification
    * CloudFunctions that listen the Cloud Pub/Sub channel to automate cost management
* Use labels to optimize the GCP budgets

To reduce cost, a possibility could be to relocate your data when sending data across a different continent, or use Cloud CDN

Recommendation:
* Labels your instances
* Analyze spend with BigQuery
* Data studio
    * turns data into a formative dashboards, and reports that are easy to read, to share and fully customizable
    * example: slice / dice your billing reports using labels
    
## Billing administration

Set buget in GCP console, with alerts based on threshold, and set emails or Cloud Pub/Sub notifications

## Stackdriver
* Integrated monitoring, logging and diagnotics
    * also error reporting, fault tracing and debugging
    * Free first usage
* Manages across platforms
    * GCP and AWS
    * Dynamic discovery of GCP with smart defaults
    * Open source agent and integrations
* Access to powerful data and analytics tools
* Collaboration with third party software

## Monitoring

Base of the SRE (Site Reliability Engineering)
* Discipline that applies aspects of software engineering operations whose goals are to create ultra scalable and highly reliable software systems
* Free book written by google SRE team

Stackdriver dynamically configures monitoring after resources are deployed, and has intelligent default that provide charts for basic monitoring activities
* Monitor platform system and application metrics by ingesting data such as metrics, events, metadata
* Generates insights from this data, through dashboards, charts and alerts
* UpTimes and healthcheck
 
Workpace: root entity that holds monitoring and configuration information
* Can have up to 100 monitored projects (one or more GCP projets and AWS accounts)
* Have as many workspace as we want
* Dashboards, alerting policies, uptime checks, notification channels and group definitions
* Access data from its monitored projects
* Always have a first project, named the hosting project.
    * The name of the project becomes the name of the workspace
* Then connects your others projects
    * for AWS: create a GCP projects that holds the AWS account number

* Users with access to the workspace have access to all the data per default
* If needs to data isolation, create multiple workspaces

* Create custom dashboards
    * Instances CPU utilization, packet and bytes sent, packets dropped by the firewall
    * Customize with filters, aggregates...
* Dashboards are great when you have someone looking at them, but it is not always the case
    * Middle of the night for instance ?
* Create alerting policies for specific conditions
    * Send emails, SMS or others channel configuration to troubleshoot the problem
    * Also alerts for monitoring stackdrivers usage for the bill

Recommendation to create alerts:
* Focus on symptoms, and not on causes
    * failing queries of a database, and then identify whether the database is down
* Multiple notifications channel : SMS & E-mails.
    * Avoid SPOF
* Tell the audiences what actions need to be taken or what resources to examine
* Avoid noise, because this will cause alerts to be dismissed overtime
    * Alerts have to be Actionable (don't set up on everythings)

Uptime checks: test the availability of our instances
* HTTP, HTTPS or TCP
    * App engine app, compute instance, URL, loadbalancer...
* Create an alerting policy
* Example: Create a HTTP request, with a 10 seconds timeout periods

Stackdriver can access metrics without monitoring agent
* Standard metrics are:
    * CPU utilization, disk traffic, network traffic, uptime information
* Compute engine and EC2 instances
* 2 simple commands, to be include in the startup scripts
* Create custom metrics
    * Game server to scale based on number of connected users


## Logging
* Store search and analyse log, from GCP and AWS
* 30 days retention
* Log based metrics
* Monitoring alerts can be set on log events
* Data can be exported to
    * Cloud Storage, for more than 30 days storage
    * BigQuery for analysis
        * Network analysis, usage, forensics to analyze incident
        * Relocate VM
        * To visualize logs, this can be coupled with Data Studio, to see dashboards
    * Pub/Sub for other processing tasks
        * Streams log to applications or endpoints
        
## Error reporting

* Counts analyses and aggregates errors in running Cloud Services
* Centralized errors interfaces displays the results
    * Sorting and filtering capabilities
    * Real time notifications on error detected
* Understand GO, Java, .NET, PHP, NodeJS, Python and Ruby

## Tracing

* Distributes tracing system that collects latency data from your applications
* Display data in GCP console
* see how requests propagate through the application and receive detailed near real time performance insights
* Analyzes all application's trace to generate in-depth latency reports
* Traces form app engine, HTTPS load balancer and applications instrumented with the stackdrivers trace Drivers

## Debugging

* Inspect state of a running app in real time, no stop, no slow down
    * Adds less than 10ms to the request latency, not perceptible to the end users in most cases
* Debug snapshots
    * Capture call stack and local variables
* Debug logpoints
    * Inject logging into a service without stopping it
* Java, Python, Go, NodeJS and Ruby

Works best with source code in google repository
