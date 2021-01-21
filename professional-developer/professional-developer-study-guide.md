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
* Easy app consumption for developers
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
To graceful shutdown an instance, the application needs to handle properly a Sigterm signal.

##### Kubernetes
https://cloud.google.com/blog/products/gcp/kubernetes-best-practices-terminating-with-grace

When kubernetes decides to remove a POD to manage resources differently, it will enter the Kubernetes termination lifecycle, where it triggers:
- PreStop hook is executed. Use to close / stop tierce-API or things like that
- In parallel, it sends a SIGTERM to your application. This is the role of your application to terminate connection, storing sessions back into the storage...
- After the TerminationGracePeriod (30s by default) it sends a SIGKILL, forcibly removing the pod

##### AppEngine

AppEngine sends a ` /_ah/stop` request to your application, which has now 30 seconds to gracefully shutdown. This signal occurs when AppEngine is configured to manage the autoscaling of your application, or when you remove an instance manually.

##### Compute engines

When your Compute Engines receives a Termination command, it executes the shutdown script configured by the user when it creates the instance or the Managed Group:
* If the application receives the `instances.delete` or `instances.stop` request
* When your compute engine is preemptible
* When the user manuallu shutdown or reboot the VM, like `sudo shutdown` or `sudo reboot`
* Using the gcloud CLI
But it will not be run (the shutdown scripts) if the application receives `instances.reset`

Of course, it works the samy if your instance is part of a Managed Instance Groups and you configured an autoscaling behavior.

#### Google-recommended practices and documentation
https://cloud.google.com/docs
https://cloud.google.com/solutions/best-practices-for-running-cost-effective-kubernetes-applications-on-gke
https://cloud.google.com/appengine/docs/standard/python/microservice-performance
https://cloud.google.com/compute/docs/instance-groups

### 1.2 Designing secure applications. Considerations include:

#### Implementing requirements that are relevant for applicable regulations (e.g., data wipeout)

When designing an application, it is important to take into consideration the security principles that must be applied for the audience you are targeting. Most of the regulations are not addressed only by Google. Indeed, security regulations is a shared responsabilities between you and Google, where you need to do your part of the job.

##### ISO/IEC 27001

Google is certified ISO/IEC 27001 that helps organization keep their information asset secure. It provided a set of best practices, requirement for Information Security System (IMS) and details security controls.

##### HIPAA
Health Insurance Portability and Accountability Act of 1996 is a law that establishes data privacy and security requirements for organizations that are charged with safeguarding individuals protected health information (PHI). 

##### GDPR
Defines a set of regulations to protect data regarding one individual for EU citizens.

The MOST important part here is to realize security is a shared responsabilities and you as a developer must take action in order to fulfill the applicable regulations

#### Security mechanisms that protect services and resources
https://cloud.google.com/docs/authentication/#service_accounts

To prevent access to your services and resources, you need to configure IAM. IAM is based on roles and permissions.

* A role is a set of permission that gives access to resources and services hosted on GCP.
* A role is granted to a set of members or groups that must perform actions on GCP
* You must follow the principle of least privileges when assigning rights, which means to need grant more than the member needs to perform its actions
* Members can be added to a group. Groups are used to managed more easily the different rights.

When we talk about users in GCP, we identify differents members:
* Service account: To authenticate a GCP resources or services
* Google Account: to authenticate an end user (with password, or SSO...)
* Google group: to group members inside the same group (like function, or profile to more easily managed company policies)
* Cloud identity domain

The identity of a GCP members is an email.

#### Security mechanisms that secure/scan application binaries and manifests
Container analysis is the tool provided by GCP to scan and analyse images on Artifact Registry and Container Registry. It provides a REST API consumable to retrieve metadata computed about your different images/artifact.

Please note Container Analysis is now a paid services and needs to be enable in the Container and Artifact registry.

It analyses the layer your image is based on and generates a report with different level of severity.

#### Storing and rotating application secrets and keys (e.g., Cloud KMS, HashiCorp Vault)

##### Key Management System
Any GCP users can use their custom security keys using KMS (Key management system). A KMS is store that contains all user-supplied and google-managed cryptographic key.

In KMS, you can store symmetric and asymmetric key.

To store encryption keys, you need to use KMS.
https://www.qwiklabs.com/focuses/1713?parent=catalog

You can store Google managed key in KMS by creating a KeyRings and a Cryptographic key
```shell script
gcloud kms keyrings create $KEYRING_NAME --location global

gcloud kms keys create $CRYPTOKEY_NAME --location global \
      --keyring $KEYRING_NAME \
      --purpose encryption
```

Then, to encrypt/decrypt data, you can interact with the KMS public API
```
curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:encrypt" \
  -d "{\"plaintext\":\"$PLAINTEXT\"}" \
  -H "Authorization:Bearer $(gcloud auth application-default print-access-token)"\
  -H "Content-Type: application/json"

curl -v "https://cloudkms.googleapis.com/v1/projects/$DEVSHELL_PROJECT_ID/locations/global/keyRings/$KEYRING_NAME/cryptoKeys/$CRYPTOKEY_NAME:decrypt" \
  -d "{\"ciphertext\":\"$(cat 1.encrypted)\"}" \
  -H "Authorization:Bearer $(gcloud auth application-default print-access-token)"\
  -H "Content-Type:application/json" \
| jq .plaintext -r | base64 -d
```

Then, you can configure IAM permissions to manage access to key and keyrings:
* cloudkms.admin: allows anyone with the permission to create KeyRings and create, modify, disable, and destroy CryptoKeys
* cloudkms.cryptoKeyEncrypterDecrypter: is used to call the encrypt and decrypt API endpoints.

You can upload encrypted data into Cloud Storage, and decrypt it in your application, making sure the information is never publicly accessible.

##### Hashicorp vault
To store secret, you can use the Hashicorp Vault secret manager.
https://www.qwiklabs.com/focuses/1210?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&parent=catalog&search_id=8610803

Basically, deploy a Hashicorp vault into a Compute engine instance and configure Google to communicate with this instance.

Configure 2 environment variables:
```shell script
export VAULT_ADDR="$(terraform output vault_addr)"
export VAULT_CACERT="$(pwd)/ca.crt"
```
And then use the `vault` command (the vault tool needs to be installed first on your system. It will then communicate with the Vault on the compute engine)
```shell script
vault operator init \
    -recovery-shares 5 \
    -recovery-threshold 3
```

Don't forget, your compute engine instance needs to be available for remote TCP connection (configure a TCP Load Balancer with firewall rules to allow 80/443 connection)

#### Authenticating to Google services (e.g., application default credentials, JSON Web Token (JWT), OAuth 2.0)

Authenticating a GCP services a available with:
* An application default credentials. If your services need to access another GCP services, then the application will lookup for a  `GOOGLE_APPLICATION_CREDENTIALS` environment variable containing the credentials information. 
    * By default, every Google Services have a service account with Editor Role (to be validated if ALL default account are EDITOR). But the best practices would be to create a specific service account and restrict access to unnecessary services/resources.
* Tje OAuth 2.0 protocol, you can authenticate an end user to access your services. This is useful if you need to know the end user accessing the resources
* An API Key, handy when the resources is protected and you don't need to know the identity of the users/services accessing the resources.

To authenticate an end user, but more freely, with no restriction to the IAM configuration, you can also use the Cloud Identity Platform services, you can also authenticate end users with a JWT token. The request is sent with the Firebase admn SDK to the authentication service, a JWT is sent to the user, which passes it to the resources server. The server asks firebase if the token is valid to grant access to the resources.

https://cloud.google.com/docs/authentication

#### IAM roles for users/groups/service accounts

IAM is the GCP service to manage access to GCP services. You can configure:
* user accounts: To authenticate end user to access the platform
* service accounts: To authenticate services to communicate with one another
* Groups : to group user/services into groups to easily manages roles

A role is a set of permission to grant access to GCP services. Google provides `Predefined roles`, the default ones.

You need to respect the principle of least privileges to avoid uncesseary access to users and so security leaks.

Within an organization, you can define roles to users on the organization or folder level. Once an access is granted at a higher level, it can't be revoked in a project. Be careful with that !

You can create your own roles if needed, by assembling permissions together. Those roles are called `custom role`

The previous version of IAM os still working, where you find 3 `basic roles`:
* VIEWER : Read action that do not affect state
* EDITOR : VIEWER + changing existing states (adding resources, updating, deleting...)
* OWNER : EDITOR + Roles management + Billing management

Do not use basic roles on production...

#### Securing service-to-service communications (e.g., service mesh, Kubernetes Network Policies, and Kubernetes namespaces)

A service mesh is an infrastructure layer built with your application to manage, observe and secure communications across your services (like retry policy ?). It enables the developer to focus on coding business value, and not dealing with basic infrastructure code.

In your entire infrastructure, you can have as many service mesh as you have applications. All meshes together creates a mesh metwork.

Kubernetes comes with a service mesh, called Istio, to manage services to services communication. I guess (needs to check) that Istio is responsible for mapping the service name your service calls to send the requet to the correct PODS. Besides, with the kubernetes network policy, you can define what services can be sent to a specific pod. You also have kubernetes namespace to isolate pod together by grouping them to form a cluster logically connected together. If you want to talk to another namespace, you need to use its public HTTP entry point.

--> Training kube might be a good idea

#### Running services with least privileged access (e.g., Workload Identity)

It is a best practice to ensure your application runs with the least privilege it needs to success in its task. By default, a GCP service has EDITOR basic roles. It is always good to create a specific service accunt for a specific Workloads with the minimal roles.

Like when running a service in Cloud Run, you can also configure the service account for a Compute engine instance (at creation), when using GKE and running PODS, or even with App Engine (for a specific services ?)  

#### Certificate-based authentication (e.g., SSL, mTLS)

To access a GCP services with a LoadBalancer, you can use Google managed certificate or your own custom certificate. When requesting a server, if HTTPS is used, the client will encrypt the request the public key of the target server. The public key is managed by central organization that contains all public key for a specific websites. The request is then decrypted by the server with its private key. For websites, everybody has access to the server public key.

For an internet, the public key might not be known by global organization. In this case, you need to configure your client to add the public key (certificate) into your machine to encrypt data sent to the server (and also using the client private key to decrypt the data).

A LoadBalancer can have multiple SSL certificates. The client can specify what certificates to use.
Using SSL is a way to ensure a secured communication, but you can not know the identity of the caller. For this, you need to use Google Authentication solutions.

#### Google-recommended practices and documentation
https://cloud.google.com/load-balancing/docs/ssl-certificates

### 1.3 Managing application data. Considerations include:

#### Defining database schemas for Google-managed databases (e.g., Firestore, Cloud Spanner, Cloud Bigtable, Cloud SQL)

##### Firestore

A NoSQL storage solution to store Documents (like MongoDB). To create a good schema, you need to take into considerations the use cases or your application in term of reads/writes. Indeed, Firestore has a limit of 1 write per second on an Entity. If you go over that limit, you can face contention and latency occurs (with failed requests also). 
* A document can not be bigger than 1Mo
* An entity key size is limited to 6Ko
* You can nest entities in entities. But you are limited to 20 nested levels.
* To query a data, an index has to be created first. No index, No query.
* APi size request: 10Mo

##### Cloud Spanner

A distributed RDBMS to handle heavy reads/writes to a SQL database. Use this if your CloudSQL can't handle the loads. Just like in any SQL database, you define:
* Tables with attributes
* Tables with relationships to other Tables (foreign Key)
    * With Spanner, you can create interleaved table (nested the child table directly into the parent table to increase query)

To have more info, see "Defining a key structure for high-write applications using Cloud Storage, Cloud Bigtable, Cloud Spanner, or Cloud SQL"

##### Cloud BigTable

The key point is to understand that a schema in BigQuery is designed for the query you plan to use. See "Defining a key structure for high-write applications using Cloud Storage, Cloud Bigtable, Cloud Spanner, or Cloud SQL" to have more information regarding rowkey.

BigTable is:
* A Key/Value storage system
* Only the RowKey is indexed (which explain why you need to think query first, unlike a RDBMS system where you can add more indexes)
* Rowkeys are sorted lexicographically
* Group column into a Column fa;ily
* Column in a Column family are sorted in lexicographic order
* All operations are atomic on a RowLevel
* Intersection of Row + Column can contain multiple timestamped cells (a unique version of the data)
* You need to distribute reads and writes evenly
* Tables are sparse => an empty cell does not take place on the storage

##### Cloud SQL

RDBMS system. Just rely on Cloud Spanner, both are equivalent on term of Schema. Just notice in classic RDBMS, you can not have interleaved table, you can only express table relationships with Rowkey. Just like any other system, you can create index on some column, groups of colums. Define also Primarey key (automatically indexed).

#### Choosing data storage options based on use case considerations, such as:
##### Time-limited access to objects

Objects in Cloud Storage does not need to be accessed all the times. By using a `Signed URL`, you can set a duration that ensure the validaty of the access within the timeframe you specified.

##### Data retention requirements

Retention policies are used to define a minimal time an object needs to be preserved before doing any modification. Before this time, the object can not be deleted or modified (but metadata can). 

Cloud Storage offers the possibility to configure a bucket with a retention policy to ensure an object will not be modified later, before the retention policy has passed.
* Retention policy can be set on bucket creation or on an existing bucket

Keep in mind:
* A retention policy can be locked. You can change it after.
* You can still edit object's metadata
* Retention policy contains an effective time
* To see when an object will be modifiable again, see the "retention expiration date" on the objet's metadata
* You can combine lifecycle management with retention. The deletion of an object by the lifecycle will occur only if the object has passed the retention period
* You can't combine object versioning and retention policy 

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