# Certification exam guide

## Section 1: Designing highly scalable, available, and reliable cloud-native applications

### 1.1 Designing high-performing applications and APIs. Considerations include:

#### Microservices

A microservice is a small application focused on solving a specific use cases. We can find some good microservice architecture in a DDD project, where a bounded context is a natural boundary to define a microservice.

Most of the times, people see microservices as a silver bullet, without thinking globally about all the problems that arise:
- Latency when communicating between microservices across networks
- Cascading failure in the system
- Scalability is not free (cost money to run a service)
- CAP theorem (Consistency, Availability and Partition tolerance)

#### Scaling velocity characteristics/tradeoffs of IaaS (infrastructure as a service) vs. CaaS (container as a service) vs. PaaS (platform as a service)

IAAS: Infrastructure as a service. The provider provides infrastructure, like virtual machines, network configuration). Google Compute Engine is an example of IAAS.
* You have a full control of what you deploy, how you manage it. But that gives you more responsibilities, in terms of configuration, security, upgrades...
* You also have to create everything yourself, like autoscaling and other applicative stuff.

CAAS: Container as a service. Run your container without managing the underlying server. Google Kubernetes Engine is an example of CAAS. Based upon Kubernetes to manage your containers in a cluster of machines managed by Google.
* You do not control the underlying VM, but with Kubernetes, you have a more fine-grained control over your deployments. Of course, you need to manage yourself your Deployments upgrades in version, the communication inside your cluster, the exposition of your application using HTTP Load Balancer...

PAAS: Platform As a Service. Run your application easily without any server management. AppEngine is an example of PAAS.
* You focus only on the code, and with light configurations (.yml file) you can configure autoscalings for your application

#### Geographic distribution of Google Cloud services (e.g., latency, regional services, zonal services)

Google Cloud infrastructures are located in different part of the world called region. A region has 3 or more zones. Each region must be XXX miles apart from each other, in order to ensure robustness in case of a natural disaster, or general system failure.

Some resources are zonal, which means they are dedicated to a zone, and can be accessed only with resources in the same zone. Others are regional, which means you can access them is your resource is also located in the region.

The selection of a region or a zone can affect latency depending on the location of your end users. Consider the physical location of your user when choosing a region or zones to ensure a quality of service and fast exchange.

#### Defining a key structure for high-write applications using Cloud Storage, Cloud Bigtable, Cloud Spanner, or Cloud SQL

##### Cloud Storage

Cloud Storage is the storage system to store binary object, like file. It is not a Database, nor a FileSystem. 

Upload and download files with similarities to a FS. A bucket has limited capabilities:
* Writes: 1000 objects write per second (uploading, updating and deleting objects)
* Reads: 5000 objects reads per second (listing objects, reading object data and metadata)
A bucket is designed for autoscalability. By default, with the rates specified above, you can write up to 2.5Pb and read 13Pb in a month for 1Mb objects.

If your application goes beyond those needs, you can increase the IO by ramping up your application. By by matching the default rate, and then ramp up every 20 minutes by doubling the request rate.

In case of high-write applications, like dataflow process, you might faced some latency, contention or even errors if your buckets are not properly designed.

In a bucket, the objects are indexed by Google to distribute the workloads across the different servers. If your objects key are in small range, then you increase the risk of Contention. Hopefully, Google detects such case and redistribute the loads across others available servers.
      
Avoid using keys based on sequential information or timestamp. Those are no good choice to ensure a even distribution loads across your servers. Make sure to include some randomness in the object key to ensure an even distribution.

Example:
* This is bad because you use a timestamp information to build the object key. 
```text
my-bucket/2016-05-10-12-00-00/file1
my-bucket/2016-05-10-12-00-00/file2
my-bucket/2016-05-10-12-00-01/file3
```
* A better approach is prefixing the object key with the first 6 digits of the MD5 representation of the object key.
```text
my-bucket/2fa764-2016-05-10-12-00-00/file1
my-bucket/5ca42c-2016-05-10-12-00-00/file2
my-bucket/6e9b84-2016-05-10-12-00-01/file3
```
* Adding randomness after a common prefix is also effective for that particular prefix. If you have high-writes only to a certain part of your Bucket, you can add randomness only for that specific part.
```text
my-bucket/images/animals/4ce4c6af-6d27-4fa3-8a91-5701a8552705/1.jpg
my-bucket/images/animals/9a495e72-1d85-4637-a243-cbf3e4a90ae7/2.jpg
...
my-bucket/images/landscape/585356ac-ce89-47a8-bdd2-78a86b58fee6/1.jpg
my-bucket/images/landscape/2550ae5b-395e-4243-a29b-bbf5aece60ef/2.jpg
...
my-bucket/images/clouds/1.jpg
my-bucket/images/clouds/2.jpg
```

Another way to achieve high-writes for a bulk operation is using uploading files and folder in parallel without following the sequential folder names, which could cause an uneven distribution for the writes application.

In summary: 
* Use randomness on your object key to avoid contention
* Executes bulk operations without following your sequential folders structure to writes object into Cloud Storage

##### Cloud BigTable

Cloud BigTable is the databases to handle typical BigData use cases. Similar to HBase (you can use hbase client to send information to Cloud BigTable) it offers very high writes and reads with very low latency. You can also enjoy some nice features like:
- a simple way to administrate your database, like adding new cluster without impacting data durability, or performance
- High scalability juste by adding new machines into the cluster
- Cluster resizing without downtime

Cloud BigTable is a key/value databases, where values can not be larger han 10Mb. To handle high-writes application, the key is to design the key to avoid hotspot... Just like Cloud Storage, the load needs to be distributed evenly to ensure high performance, no contention and low latency.

Typical use cases for BigTable:
* Time-series data, such as CPU and memory usage over time for multiple servers.
* Marketing data, such as purchase histories and customer preferences.
* Financial data, such as transaction histories, stock prices, and currency exchange rates.
* Internet of Things data, such as usage reports from energy meters and home appliances.
* Graph data, such as information about how users are connected to one another.

Cloud BigTable stores Rows. Each row are indexed with a Row. A Row contains multiple Column, group into a Family. A column name must be unique inside a column family. BigTable is sparsed, which means empty cell does not take space in memory. Column family and column can be added on the fly, without much effort.

By design, the rowkey is the most important part to ensure an even distribution of the workload. To properly design a rowkey, you need to know the query you will perform on your data.
Most efficient queries are query using :
* the row key exactly
* The prefix of the row key. Avoid finding elements where the attribute your are looking for is in the middle of the row key, this will cause major latency (alos known as FullTable scans)
* Range of row keys by starting and ending rowkeys.

Cloud BigTables stores data lexicographically, which means 3 > 20, but 20 > 03.
* The Rowkey is composed of multiple value. MAke sure you use a proper rowkey separator 
* So, if you store integer in your RowKey, pad with leading zeroes.
* Also, a rowkey should be short : 4Kb. Larger keys results in lower performance
* Design the rowKeys to retrieve a well-defined range of rows

Important considerations for RowKey:
* Design your row key based on the queries you will use to retrieve the data
* Keep your row keys short (less than 4Kb). Larger keys results in lower performance
* Pad the integers with leading zeroes
* Create a row key that makes it possible to retrieve a well-defined range of rows
* Use human-readable string value whenever possible. (use Key Visualizer tool to troubleshoot issues)
* Design rowKeys that start with a common value and end with a granular value (continent#country#city for instance)

RowKeys to avoid
* Row keys that start with a timestamp. This cause sequential writes to be pushed on a single node, creating a HotSpot. If you have a timestamp in your RowKey, precedes the values with high cardinality value, like user Id
* Rowkeys that cause related data not to be grouped together.
* Sequentials numeric Ids. The most recent are the ones using the most the application. Therefore, pushing their actions on BigTable will cause a Hotspot. A solution is to use a reversed version of the user's numeric ID. This will spread the loads more evenly.
* Frequently updated identifiers. It is better to store events with a timestamp in the row instead of storing the updates value for a specific identifiers. Of course, do not use the timestamp as the first element of the rowKey (hotspot). Instead, use other information, like deviceId#metric#timestamp. Use a query to collect all events for a range of date on a particular device for a specific metric for instance.
* Hashed values: Hashing removes the ability to take advantage of Cloud BigTable natural sorting order.
* Values expressed as raw bytes: Prefer human readable strings. Rawbytes are fined for column values.

##### Cloud Spanner

Cloud Spanner is used to handle Relational Databases in a very demanding environment, where the clients needs high-writes. It is very similar to a relational database, in which you define your tables containing columns and primary keys.

Usually, in a classic RDBMS, you define relationships in your tables. Those relationships are created using Foreign Keys, used to join table together. To provide better performance, Cloud Spanner adds the feature of "interleaved tables" where you define a relationships between tables not by foreign key, by by sharing the primary of the parent table. It is like a parent/child relationships. Cloud Spanner stores "interleaved tables" data differently by using the same physical storage to group the data together. In term of storage, the child data is stored between two parents rows. Child data must share the exact same column in the exact same order as the PK of the parent table.

Primary keys:
* are automatically indexed and sorted alphabetically.
* contains as many columns as needed
* Must NOT be a basic auto-increment integer as it creates a HotSpot. Indeed, Spanner divided data based on key range... If you have an auto-increment value, then your data will always be redirected to the same node, until the key range is fullm and then going onto the next one..

PK best practices:
* Hash the key and store it into a single column
* Swap the order of the column
* Use a UUID (universally Unique identifier) Version 4 is best. Version 1 not so much as the timestamps is the high order bits
* Bit-reverses sequential value

Good things to know:
* Schema design best practice #1: Do not choose a column whose value monotonically increases or decreases as the first key part for a high write rate table.
* Schema design best practice #2: Use descending order for timestamp-based keys.
* Schema design best practice #3: Do not create a non-interleaved index on a high write rate column whose value monotonically increases or decreases.


##### Cloud SQL
 
Cloud SQL is the GCP solution for simple SQL Database. PostgreSQL, MySQL and SQL Server are available. 

As it is a classic RDBMS system, there is no need to design for high-writes application... It does not scale as much as Spanner any way. If you are really looking for high-writes in a Relational databases, then consider using Spanner.

To design CloudSQL for high writes, the solution will be in the architectural choices, like using more replicas to distribute the workload.
 
#### User session management

To manage a User session (i.e data related to a user for the time he is using the application) you can use different features:
* An External Load balancer has a *session affinity* configuration, to dispatch the client in the same backend server

Session are usually managed at the application level. If the application is specific to a single application, then, in case of scalability, you need to make sure the client will always be redirected to the same server. To do that, you can use an External Load balancer with a  *session affinity* configuration, to dispatch the client in the same backend server.

You could also lever some GCP databases solution to handle such a use case. 2 databases might fit your needs:
* Memory store: blazing fast redis in memory database to store and handle data.
* Firestore: NoSQL solution suited to store user related data to manage the session

#### Caching solutions

A famous caching solution is MemoryStore. A Redis database very fast that is perfect to handle cached information with very fast read rates. MemoryStore can be used with several Google services like AppEngine, Compute Engine, Cloud Functions, Cloud Run and GKE.

Another caching solution more web oriented is the usage of the CDN (Content Delivery Network) where you can cache your web content to deliver content very fast to the different users around the world.
To use the CDN, you need to configure an external Load Balancer with a SSL certificate.

#### Deploying and securing API services

Basically, you can deploy any application, either using a PAAS solution, a CAAS or a IAAS. To access your service, you need loadBalancer (most of the times) to gives your application a public name outside users can use. Sometimes, to accomodate company policy or others constraints, like progressive service migration, you might want to use an API gateway, that serves as a Proxy to ensure the request is handled by the correct service. Of course, an API does more, like monitoring the activity, configuring security access or defining the API mapping based on OpenAPI specification for instance.

Regarding securities, you don't want your API to be accessible publicly. Here again, API gateway can be very handy to help configuring API restriction. 

There is also other way to protect your services:
* Configure your VPC with Firewalls rules to ensure your private service are not exposed
* Use Identity aware proxy to ensure only a valid Google account can accessed your application
* Secure your application with a Token validation. This token can be provided by a GCP service account, or by an end user (Identity platform for instance).
* Some PAAS can also be configured to handle the security without requiring an application validation, like cloud run, functions or App engine, where you can disable public invocation.

##### Cloud Apigee
https://cloud.google.com/apigee/docs/api-platform/get-started/what-apigee

Cloud Apigee is a platform for developing and managing API proxies. The purpose is to act as a gateway API before letting the clients accessing your backend services. An API Proxy is a proxy accessed by the user before entering your GCP services. The purpose is to add functionalities like :
* security
* rate limiting
* Quotas
* Caching & persistence
* Analytics
* Transformations
* CORS
* Fault handing
* And so more

From all API management solutions, this one seems to be the more complete with the more possibilities. But you might have less freedom for others aspects (?)

##### API gateway

Provides a secure access to services through a well-defined REST API that is consistent across your services.
* Easy app consu;ption for developers
* Change the backend implementation without affecting the public API
* Scaling, monitoring and security features built in.

To configure the security, you can use:
* API keys: restrict access to specific methods or all methods in an API. To authenticate to a Gateway using an API key, provide the key as query param. Access public data anonymously
* GCP service accounts: Access private data on behalf of an end user
* Google ID tokens: A JWT that contains the OpenID connect fields needed to identify a Google user.

##### Cloud Endpoints

Endpoints is similar to API gateway in term of API management, security configuration and activity monitoring.  

#### Loosely coupled asynchronous applications (e.g., Apache Kafka, Pub/Sub)

Your microservices might need to communicate asynchronously with each other. Sending this kind of message can be carried by the GCP Pub/Sub solution. An asynchronous message system based on :
* TOPICS: where the clients will push the message
* SUBSCRIPTIONS: reads message fron the TOPIC. There is 2 kinds of subscriptions:
    * PULL: the most common, where the client pulles the message in the subscriptions.
        * Be careful, you can't pull with CloudRun, as Cloudrun runs only when an HTTP request enters 
    * PUSH: where PubSub pushes the message to an endpoint manages by one of your service
        * When pushing, consider security issue. You can ask PubSub to use a token that will be sent to your server in the "AUTHORIZATION" header. Then, either your server knows how to handle the token, or you configured your application to accept a GCP service account token.
* MESSAGE: the data transferred into PubSub

PubSub main characteristics:
* Publication of message respect the order it was published
* At least once delivery, which means sometimes, the message can be pushed twice. Think of this when designing your application 
* Once a message in a subscription has been ACKED, the message won't be sent again

Since recently, you can use an Apache Kafka cluster managed by Confluent. Apache kafka features for this level of information are quite similar to PubSub

#### Graceful shutdown on platform termination
PAAS ? Stopping instance ?
#### Google-recommended practices and documentation
?

### 1.2 Designing secure applications. Considerations include:

#### Implementing requirements that are relevant for applicable regulations (e.g., data wipeout)
RGPD ?
#### Security mechanisms that protect services and resources
https://cloud.google.com/docs/authentication/#service_accounts

#### Security mechanisms that secure/scan application binaries and manifests
security scanner

#### Storing and rotating application secrets and keys (e.g., Cloud KMS, HashiCorp Vault)
#### Authenticating to Google services (e.g., application default credentials, JSON Web Token (JWT), OAuth 2.0)
#### IAM roles for users/groups/service accounts
#### Securing service-to-service communications (e.g., service mesh, Kubernetes Network Policies, and Kubernetes namespaces)
#### Running services with least privileged access (e.g., Workload Identity)
#### Certificate-based authentication (e.g., SSL, mTLS)
#### Google-recommended practices and documentation

### 1.3 Managing application data. Considerations include:

#### Defining database schemas for Google-managed databases (e.g., Firestore, Cloud Spanner, Cloud Bigtable, Cloud SQL)
#### Choosing data storage options based on use case considerations, such as:
##### Time-limited access to objects
##### Data retention requirements
##### Structured vs. unstructured data
##### Strong vs. eventual consistency
##### Data volume
##### Frequency of data access in Cloud Storage
#### Google-recommended practices and documentation

### 1.4 Application modernization. Considerations include:

#### Using managed services
#### Refactoring a monolith to microservices
#### Designing stateless, horizontally scalable services
#### Google-recommended practices and documentation


## Section 2: Building and testing applications

### 2.1 Setting up your local development environment. Considerations include:

#### Emulating Google Cloud services for local application development
#### Creating Google Cloud projects
#### Using the command-line interface (CLI), Google Cloud Console, and Cloud Shell tools
#### Using developer tooling (e.g., Cloud Code, Skaffold)

### 2.2 Writing efficient code. Considerations include:

#### Algorithm design
#### Modern application patterns
#### Software development methodologies
#### Debugging and profiling code

### 2.3 Testing. Considerations include:

#### Unit testing
#### Integration testing
#### Performance testing
#### Load testing

### 2.4 Building. Considerations include:

#### Source control management
#### Creating secure container images from code
#### Developing a continuous integration pipeline using services (e.g., Cloud Build, Container Registry) that construct deployment artifacts
#### Reviewing and improving continuous integration pipeline efficiency


## Section 3: Deploying applications

### 3.1 Recommend appropriate deployment strategies using the appropriate tools (e.g., Cloud Build, Spinnaker, Tekton, Anthos Configuration Manager) for the target compute environment (e.g., Compute Engine, Google Kubernetes Engine). Considerations include:

#### Blue/green deployments
#### Traffic-splitting deployments
#### Rolling deployments
#### Canary deployments

### 3.2 Deploying applications and services on Compute Engine. Considerations include:

#### Installing an application into a virtual machine (VM)
#### Managing service accounts for VMs
#### Bootstrapping applications
#### Exporting application logs and metrics
#### Managing Compute Engine VM images and binaries

### 3.3 Deploying applications and services to Google Kubernetes Engine (GKE). Considerations include:

#### Deploying a containerized application to GKE
#### Managing Kubernetes RBAC and Google Cloud IAM relationships
#### Configuring Kubernetes namespaces
#### Defining workload specifications (e.g., resource requirements)
#### Building a container image using Cloud Build
#### Configuring application accessibility to user traffic and other services
#### Managing container lifecycle
#### Define Kubernetes resources and configurations

### 3.4 Deploying a Cloud Function. Considerations include:

#### Cloud Functions that are triggered via an event from Google Cloud services (e.g., Pub/Sub, Cloud Storage objects)
#### Cloud Functions that are invoked via HTTP
#### Securing Cloud Functions

### 3.5 Using service accounts. Considerations include:

#### Creating a service account according to the principle of least privilege
#### Downloading and using a service account private key file


## Section 4: Integrating Google Cloud services

### 4.1 Integrating an application with data and storage services. Considerations include:

#### Read/write data to/from various databases (e.g., SQL)
#### Connecting to a data store (e.g., Cloud SQL, Cloud Spanner, Firestore, Cloud Bigtable)
#### Writing an application that publishes/consumes data asynchronously (e.g., from Pub/Sub)
#### Storing and retrieving objects from Cloud Storage

### 4.2 Integrating an application with compute services. Considerations include:

#### Implementing service discovery in GKE and Compute Engine
#### Reading instance metadata to obtain application configuration
#### Authenticating users by using OAuth2.0 Web Flow and Identity-Aware Proxy
#### Authenticating to Cloud APIs with Workload Identity

### 4.3 Integrating Cloud APIs with applications. Considerations include:

#### Enabling a Cloud API
#### Making API calls using supported options (e.g., Cloud Client Library, REST API or gRPC, APIs Explorer) taking into consideration:
#### Batching requests
#### Restricting return data
#### Paginating results
#### Caching results
#### Error handling (e.g., exponential backoff)
#### Using service accounts to make Cloud API calls


## Section 5: Managing application performance monitoring

### 5.1 Managing Compute Engine VMs. Considerations include:

#### Debugging a custom VM image using the serial port
#### Diagnosing a failed Compute Engine VM startup
#### Sending logs from a VM to Cloud Logging
#### Viewing and analyzing logs
#### Inspecting resource utilization over time

### 5.2 Managing Google Kubernetes Engine workloads. Considerations include:

#### Configuring logging and monitoring
#### Analyzing container lifecycle events (e.g., CrashLoopBackOff, ImagePullErr)
#### Viewing and analyzing logs
#### Writing and exporting custom metrics
#### Using external metrics and corresponding alerts
#### Configuring workload autoscaling

### 5.3 Troubleshooting application performance. Considerations include:

#### Creating a monitoring dashboard
#### Writing custom metrics and creating log-based metrics
#### Using Cloud Debugger
#### Reviewing stack traces for error analysis
#### Exporting logs from Google Cloud
#### Viewing logs in the Google Cloud Console
#### Reviewing application performance (e.g., Cloud Trace, Prometheus, OpenTelemetry)
#### Monitoring and profiling a running application
#### Using documentation, forums, and Google Cloud support