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
* You do not control the underlying VM, but with Kubernetes, you have a more fine-grained control over your deployments. Of course, you need to manage yourself your Deployments upgrades, the communication inside your cluster, the exposition of your application using HTTP Load Balancer...

PAAS: Platform As a Service. Run your application easily without any server management. AppEngine is an example of PAAS.
* You focus only on the code, and with light configurations (.yml file) you can configure autoscalings for your application

#### Geographic distribution of Google Cloud services (e.g., latency, regional services, zonal services)

Google Cloud infrastructures are located in different part of the world called region. A region has 3 or more zones. Each region must be XXX miles apart from each other, in order to ensure robustness in case of a natural disaster, or general system failure.

Some resources are zonal, which means they are dedicated to a zone, and can be accessed only with resources in the same zone. Others are regional, which means you can access them is your resource is also located in the region.

The selection of a region or a zone can affect latency depending on the location of your end users. Consider the physical location of your user when choosing a region or zones to ensure a quality of service and fast exchange.

#### Defining a key structure for high-write applications using Cloud Storage, Cloud Bigtable, Cloud Spanner, or Cloud SQL

##### Cloud Storage

Cloud Storage is the storage system to store binary object, like file. It is not a Database, nor a FileSystem. 

Upload and download files with similarities to a FileSystem. A bucket has limited capabilities:
* Writes: 1000 objects write per second (uploading, updating and deleting objects)
* Reads: 5000 objects reads per second (listing objects, reading object data and metadata)

A bucket is designed for autoscalability. By default, with the rates specified above, you can write up to 2.5Pb and read 13Pb in a month for 1Mb objects.

If your application goes beyond those needs, you can increase the IO by ramping up your application. By matching the default rate, and then ramp up every 20 minutes by doubling the request rate.

In case of high-write applications, like dataflow process, you might faced some latency, contention or even errors if your buckets are not properly designed.

In a bucket, the objects are indexed by Google to distribute the workloads across the different servers. If your objects key are in small range, then you increase the risk of Contention. Hopefully, Google detects such case and redistribute the loads across others available servers.
      
Avoid using keys based on sequential information or timestamp. Those are no good choice to ensure an even distribution loads across your servers. Make sure to include some randomness in the object key to ensure an even distribution.

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

Cloud BigTable stores Rows. Each row are indexed with a RowKey. A Row contains multiple Column, grouped into a Family. A column name must be unique inside a column family. BigTable is sparsed, which means empty cell does not take space in memory. Column family and column can be added on the fly, without much effort.

By design, the rowkey is the most important part to ensure an even distribution of the workload. To properly design a rowkey, you need to know the query you will perform on your data.

Most efficient queries are query using :
* the row key exactly
* The prefix of the row key. Avoid finding elements where the attribute your are looking for is in the middle of the row key, this will cause major latency (alos known as FullTable scans)
* Range of row keys by starting and ending rowkeys.

Cloud BigTables stores data lexicographically, which means 3 > 20, but 20 > 03.
* The Rowkey is composed of multiple value. Make sure you use a proper rowkey separator 
* If you store integer in your RowKey, pad with leading zeroes.
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

Cloud Spanner is used to handle Relational Databases in a very demanding environment, where the clients need high-writes. It is very similar to a relational database, in which you define your tables containing columns and primary keys.

Usually, in a classic RDBMS, you define relationships in your tables. Those relationships are created using Foreign Keys, used to join table together. To provide better performance, Cloud Spanner adds the feature of "interleaved tables" where you define a relationship between tables not by foreign key, but by sharing the primary of the parent table. It is like a parent/child relationships. Cloud Spanner stores "interleaved tables" data differently by using the same physical storage to group the data together. In terms of storage, the child data is stored between two parents rows. Child data must share the exact same column in the exact same order as the PK of the parent table.

Primary keys:
* are automatically indexed and sorted alphabetically.
* contains as many columns as needed
* Must NOT be a basic auto-increment integer as it creates a HotSpot. Indeed, Spanner divided data based on key range... If you have an auto-increment value, then your data will always be redirected to the same node, until the key range is full and then going onto the next one..

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

Sessions are usually managed at the application level. If the session is specific to a single application, then, in case of scalability, you need to make sure the client will always be redirected to the same server. To do that, you can use an External Load balancer with a  *session affinity* configuration, to dispatch the client in the same backend server.

You could also lever some GCP databases solution to handle such a use case. 2 databases might fit your needs:
* Memory store: blazing fast redis in memory database to store and handle data.
* Firestore: NoSQL solution suited to store user related data to manage the session

#### Caching solutions

A famous caching solution is MemoryStore. A Redis database very fast that is perfect to handle cached information with very fast read rates. MemoryStore can be used with several Google services like AppEngine, Compute Engine, Cloud Functions, Cloud Run and GKE.

Another caching solution more web oriented is the usage of the CDN (Content Delivery Network) where you can cache your web content to deliver content very fast to the different users around the world.
To use the CDN, you need to configure an external Load Balancer with a SSL certificate.

#### Deploying and securing API services

Basically, you can deploy any application, either using a PAAS solution, a CAAS or a IAAS. To access your service, you need loadBalancer (most of the times) to gives your application a public name outside users can use. Sometimes, to accommodate company policy or others constraints, like progressive service migration, you might want to use an API gateway, that serves as a Proxy to ensure the request is handled by the correct service. Of course, an API does more, like monitoring the activity, configuring security access or defining the API mapping based on OpenAPI specification for instance.

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

From all API management solutions, this one seems to be the more complete with the more possibilities.

##### API gateway

Provides secured access to services through a well-defined REST API that is consistent across your services.
* Easy app consumption for developers
* Change the backend implementation without affecting the public API
* Scaling, monitoring and security features built in.

To configure the security, you can use:
* API keys: restrict access to specific methods or all methods in an API. To authenticate to a Gateway using an API key, provide the key as query param. Access public data anonymously.
* GCP service accounts: Access private data on behalf of an end user
* Google ID tokens: A JWT that contains the OpenID connect fields needed to identify a Google user.

##### Cloud Endpoints

Endpoints is similar to API gateway in term of API management, security configuration and activity monitoring.  

#### Loosely coupled asynchronous applications (e.g., Apache Kafka, Pub/Sub)

Your microservices might need to communicate asynchronously with each other. Sending this kind of message can be carried by the GCP Pub/Sub solution. An asynchronous message system based on :
* TOPICS: where the clients will push the message
* SUBSCRIPTIONS: reads message fron the TOPIC. There is 2 kinds of subscriptions:
    * PULL: the most common, where the client pulls the message in the subscriptions.
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
* When the user manually shutdown or reboot the VM, like `sudo shutdown` or `sudo reboot`
* Using the gcloud CLI
But it will not be run (the shutdown scripts) if the application receives `instances.reset`

Of course, it works the same if your instance is part of a Managed Instance Group and you configured an autoscaling behavior.

#### Google-recommended practices and documentation
https://cloud.google.com/docs
https://cloud.google.com/solutions/best-practices-for-running-cost-effective-kubernetes-applications-on-gke
https://cloud.google.com/appengine/docs/standard/python/microservice-performance
https://cloud.google.com/compute/docs/instance-groups

### 1.2 Designing secure applications. Considerations include:

#### Implementing requirements that are relevant for applicable regulations (e.g., data wipeout)

When designing an application, it is important to take into consideration the security principles that must be applied for the audience you are targeting. Most of the regulations are not addressed only by Google. Indeed, security regulations is a shared responsability between you and Google, where you need to do your part of the job.

##### ISO/IEC 27001

Google is certified ISO/IEC 27001 that helps organization keep their information asset secure. It provides a set of best practices, requirement for Information Security System (IMS) and details security controls.

##### HIPAA
Health Insurance Portability and Accountability Act of 1996 is a law that establishes data privacy and security requirements for organizations that are charged with safeguarding individuals protected health information (PHI). 

##### GDPR
Defines a set of regulations to protect data regarding one individual for EU citizens.

The MOST important part here is to realize security is a shared responsability and you as a developer must take action in order to fulfill the applicable regulations

#### Security mechanisms that protect services and resources
https://cloud.google.com/docs/authentication/#service_accounts

To prevent access to your services and resources, you need to configure IAM. IAM is based on roles and permissions.

* A role is a set of permission that gives access to resources and services hosted on GCP.
* A role is granted to a set of members or groups that must perform actions on GCP
* You must follow the principle of least privileges when assigning rights, which means to need grant more than the member needs to perform its actions
* Members can be added to a group. Groups are used to managed more easily the different rights.

When we talk about users in GCP, we identify different members:
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
Any GCP users can use their custom security keys using KMS (Key management system). A KMS is a store that contains all user-supplied and google-managed cryptographic key.

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
* The OAuth 2.0 protocol, you can authenticate an end user to access your services. This is useful if you need to know the end user accessing the resources
* An API Key, handy when the resources is protected and you don't need to know the identity of the users/services accessing the resources.

To authenticate an end user, but more freely, with no restriction to the IAM configuration, you can also use the Cloud Identity Platform services to authenticate end users with a JWT token. The request is sent with the Firebase admin SDK to the authentication service, a JWT is sent to the user, which passes it to the resources server. The server asks firebase if the token is valid to grant access to the resources.

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

The previous version of IAM is still working, where you find 3 `basic roles`:
* VIEWER : Read action that do not affect state
* EDITOR : VIEWER + changing existing states (adding resources, updating, deleting...)
* OWNER : EDITOR + Roles management + Billing management

Do not use basic roles on production...

#### Securing service-to-service communications (e.g., service mesh, Kubernetes Network Policies, and Kubernetes namespaces)

A service mesh is an infrastructure layer built with your application to manage, observe and secure communications across your services (like retry policy ?). It enables the developer to focus on coding business value, and not dealing with basic infrastructure code.

In your entire infrastructure, you can have as many service mesh as you have applications. All meshes together creates a mesh metwork.

Kubernetes comes with a service mesh, called Istio, to manage service to service communication. I guess (needs to check) that Istio is responsible for mapping the service name your service calls to send the request to the correct PODS. Besides, with the kubernetes network policy, you can define what services can communicate with a specific pod. You also have kubernetes namespace to isolate pod together by grouping them to form a cluster logically connected together. If you want to talk to another namespace, you need to use its public HTTP entry point.

#### Running services with least privileged access (e.g., Workload Identity)

It is a best practice to ensure your application runs with the least privilege it needs to success in its task. By default, a GCP service has EDITOR basic roles. It is always good to create a specific service account for a specific Workload with the minimal roles.

Like when running a service in Cloud Run, you can also configure the service account for a Compute engine instance (at creation), when using GKE and running PODS, or even with App Engine (for a specific services ?)  

#### Certificate-based authentication (e.g., SSL, mTLS)

To access a GCP services with a LoadBalancer, you can use Google managed certificate or your own custom certificate. When requesting a server, if HTTPS is used, the client will encrypt the request with the public key of the target server. The public key is managed by central organization that contains all public key for websites. The request is then decrypted by the server with its private key. For websites, everybody has access to the server public key.

For an intranet, the public key might not be known by global organization. In this case, you need to configure your client to add the public key (certificate) into your machine to encrypt data sent to the server (and also using the client private key to decrypt the data).

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

The key point is to understand that a schema in BigTable is designed for the query you plan to use. See "Defining a key structure for high-write applications using Cloud Storage, Cloud Bigtable, Cloud Spanner, or Cloud SQL" to have more information regarding rowkey.

BigTable is:
* A Key/Value storage system
* Only the RowKey is indexed (which explain why you need to think query first, unlike a RDBMS system where you can add more indexes)
* Rowkeys are sorted lexicographically
* Group column into a Column family
* Column in a Column family are sorted in lexicographic order
* All operations are atomic on a RowLevel
* Intersection of Row + Column can contain multiple timestamped cells (a unique version of the data)
* You need to distribute reads and writes evenly
* Tables are sparse => an empty cell does not take place on the storage

##### Cloud SQL

RDBMS system. Just rely on Cloud Spanner, both are equivalent on term of Schema. Just notice in classic RDBMS, you can not have interleaved table, you can only express table relationships with Foreign Key. Just like any other system, you can create index on some column, groups of colums. Define also Primarey key (automatically indexed).

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

Structured data are data you can store in GCP databases such as Spanner, BigTable, SQL or Firestore. Indeed, when storing those data, you transform the unstructured input into a structured format, with rowkey, indexes and way to fetch the data easily.

Unstructured data are all data that are basically in a binary file, which can not be queried immediatly. Cloud Storage is a perfect fit to store unstructured data, but their usage are limited.

To transform unstructured data to structured data, you can use an ETL, such as Cloud Dataprep, or Cloud DataFlow, or using an HBase cluster (provided by GCP) to transform the input data.

##### Strong vs. eventual consistency

Regarding the Database service you are using, some guaranty Strong consistency on operations, other eventual consistency. Let's delve deeper:
* Spanner: ACI++D transaction -> Strong consistency. I++ because: 
    * Isolation level is SERIALIZABLE READS (no phantom reads) for a transaction (reads-only or reads-writes)
* SQL: ACID transaction -> Strong consistency
* Firestore: ACID transaction with Isolation level at SERIALIZABLE READS -> Strong consistency
* BigTable: By default it uses eventual consistency: A write made in one cluster is eventually persisted to the others.
    * But for some cases, you can enforce a read-your-writes consistency, but you lose replication across regions for such specific data. This is configured for a group of application. Not all your applications might need a read-your-writes consistency
    * And even enforces Strong consistency for all of your applications by configuring a single-router routing (and one failover, but it is just a failover, not an available replicas to use in the workloads)

* Storage: Some operations are guarantied Strongly consistency, some others (like changing IAM permission on an object) are eventually consistent.
    * Strongly consistent operations:
        * Read-after-write
        * Read-after-metadata-update
        * Read-after-delete
        * Bucket listing
        * Object listing
    * Eventually consistent operation:
        * Granting access to or revoking access from resources.

##### Data volume

High volume of data are better handled by Cloud BigTable, Cloud Spanner and Cloud Storage. If you respect the best practices in term of schema, rowkey definition, indexes... you could create application that supports high volume traffic.

Cloud SQL and Firestore are less usable for high volumes traffic. For instance, Firestore supports high reads, but low writes (1s per entity max) and Cloud SQL, well it is basic SQL (MySQL, PostgreSQL, SQLServer)

##### Frequency of data access in Cloud Storage

Cloud storage provided 4 storage classes:
* Standard Storage: Data are accessed frequently. No retention policy by default. Very low access fees, Very high storage fees
* Nearline Storage: Data are accessed on a monthly basis. 30 days retention. Low access fees, High storage fees
* Coldline Storage: Data are accessed on a quarter basis. 90 days retention. High access fees, low storage fees
* Archive Storage. Data are accessed on an annual basis. 365 days retention. Very high access fees, very low storage fees

#### Google-recommended practices and documentation

### 1.4 Application modernization. Considerations include:

#### Using managed services

As much as possible, it is always recommended to use Managed services. By using them, you enjoy the experiences of many years on many projects for your application. If you need a database, don't use a PostgreSQL started on a Compute engine you manage yourself. Use Cloud SQL. You need a messaging system, choose PubSub. Data storage, use a Storage service...

If you do not, you might have to think about all the implications of not doing so, like resiliency, availability, backup...

#### Refactoring a monolith to microservices

Refactoring a monolith application to a microservices application should never be taken lightly. These decision will impact your entire application on subjects you never imagined before... Indeed, working in an ACID environment is a very comfortable place to be...

Besides, you will never be able to move all at once. It is mandatory to move parts after parts, gain experiences with the first API migration, and then move on to the next step.

So, you have to move step by step... Starts by creating an API gateway... The gateway will intercept the call, and then redirects it to the monolith. Once it is working properly and stable, then extract an endpoint and then change the gateway to send those specific request to the new microservices...

Besides, you will also have to think scalability: How your system will evolve under load peaks ? With a monolith, it is more likely you will perform a vertical scalability: having a more powerful system. With microservices, you can think in terms of horizontal scalability.

And then comes the questions about databases, where you can choose more accurately system that best fits your needs in term of data storage.

When talking about communication, you might need now a Pubsub system for async command, or using HTTP request for sync query... So you need to think in term of latency, throughput, Correlation ID...

And even more consideration
 
#### Designing stateless, horizontally scalable services

Stateless is becoming the new standard when developing REST API. The sessions are no longer managed on server side, which is one factor that makes horizontal scalability difficult to apply. Instead, it is delegated to the client, using Cookies, and any server can handle the client request. This makes the system more scalable.

But, in some cases, you might need session management. If it the cases, you could use solution like MemoryStore to very quickly retrieve the client session for instance.
 
#### Google-recommended practices and documentation

* No session
* Microservices development
* Managed services as much as possible

## Section 2: Building and testing applications

### 2.1 Setting up your local development environment. Considerations include:

#### Emulating Google Cloud services for local application development

Using the `gcloud` tool, you can start emulator of some services on your own computer, making your development easier and faster. The available emulator are:
* bigtable
* datastore
* firestore
* pubsub
* spanner
* (for SQL, it is easy for you to set this up)

To start an emulator, you can use:
```shell script
gcloud beta emulators GROUP COMMAND
```
With GROUP being one of the service listed above. COMMAND being specific to the GROUP.

```
gcloud beta emulators datastore start
```

#### Creating Google Cloud projects

Projects are the main resource you will need in GCP. Every resource you create are linked to a project. Do not be afraid of creating and deleting projects, are the fees only apply for services you create in the project.

To create project, you can either use the GCP console (only web application: https://console.cloud.google.com), or use the `gcloud` tool
```shell script
gcloud projects create PROJECT_NAME --set-as-default
```

Consider then two things about your project: the name and the ID. If the name is unique, then it will also be the ID. If it is not, then il will create a different ID. The ID is the unique name of your project, and must be used to know on which GCP project the resource needs to be created. 

#### Using the command-line interface (CLI), Google Cloud Console, and Cloud Shell tools

The `gcloud` tool is very handy once installed on your computer. You can manage all your instances using the CLI, and even using the emulators. For full docs, see: https://cloud.google.com/sdk/gcloud

You can also use the WebApplication if you feel like it. You can manage almost the same things when using the CLI or accessing the WebApp. 

With the WebApp, you have access to Cloud Shell, a virtual environment with the `gcloud` tool installed. Easy to execute some command to test things without impacting your entire system. 
The Cloud shell :
* is executed on a Compute Engine instance (Debian based Linux OS).
* Data inside the Compute engine is persisted, but lost after 1hours of inactivity.
* 5Go of free persistent storage mounted as $HOME.
* Storage per user, cross project.
* This storage does not timeout, unlike the instance itself. (only $HOME)
* Full documentation: https://cloud.google.com/shell/docs/how-cloud-shell-works

#### Using developer tooling (e.g., Cloud Code, Skaffold)

Cloud Code is an extension to some of the most famous IDE, like VSCode or Intellij. It helps managing Cloud native application. Some features are:
* Deploy Cloud run services
* Speed up Kubernetes development
* Easily integrate Cloud APIs
* Extends to production deployment
* Access to Cloud Storage
* Secret manager

Skaffold is also a tool provided by Google, installable on your computer. It helps you manage easily your kubernetes cluster with configuration, like namespaces, images and so on.

### 2.2 Writing efficient code. Considerations include:

#### Algorithm design

Writing algorithm should be done carefully, It is easy to solve a problem, it is hard to solve it properly. Many applications are simply application that responds to a user inout and change data in the database. But when it comes to application where logic and intelligence and required, you need to know some algorithm families in order to fallback on one of them.

* Like sorting array algorithms
* Tree analysis
* Heap..

Besides, one the most common notation to analyse an algorithm is O(n).
* O(n) which means the algorithm will evolve in a linear way given the input data size, like standard array iteration
* O(1) which indicates the algorithm will always take the same time, no matter the input data. Usually, to reach a O(1), you need to compromise with memory footprints by using a Map for instance. You reduce the time needed by increasing the memory footprint.
* O(nlogn): when you sort an array, it is always O(nlogn). Which means the more input data you have, wider the gap will be between two execution N and N+1
* O(n^2): Should be avoided, as the algorithm time will increase exponentially as the input data grows... in other words, it doesn't scale and should be avoided.

#### Modern application patterns

In the Cloud, Microservices is the main modern application pattern. You split your services with well defined responsabilities to ensure the success of your use cases.
Those services will communicate with one another using HTTP request, or sending async message. The major difficulties with microservices is to find a proper split. And of course, there is no single solution. One very known anti-pattern is to split the services by technical consideration, which diminishes the horizontal scalability possibilities.

To split properly the microservices, the usage of strategic DDD could be helpful in order to find natural boundaries between microservices, and avoiding the pattern of putting every new code in a new microservices.

You also find the classic 3 tiers application: Frontend, backend and Database.
This approach is very common the layering architecture inside an application: Controller / Service / Infrastructure.

Nowadays, when applicable, we hear a lot about DDD application: 
* Hexagonal architecture, with Primary/driving adapters (left side) and Secondary/Driven adapters (right side). (https://alistair.cockburn.us/hexagonal-architecture/)
* Exposition layer
* Infrastructure Layer
* Application layer
* Domain Layer
* The overall idea is to easily change a technical implementation, like database access, pubsub system for another one, without impacting the business (domain layer) code.

Of course, with GCP, the micro services pattern with each services its own storage service is more than encourages, in order to facilitate scalability of your application.

#### Software development methodologies

Agile methodologies are famous currently to build a software:
* Developers and clients proximity
* Constant communication with the clients
* Features Priorization
* Possibility to adapt if market or needs evolve

Software Craftsmanships:
* SOLID
    * SRP: Single responsabilty: a class has one reason to change
    * OCP: Open for extension, close for modification: Adding features can be done by extending current behavior
    * Liskov: A child can not refuse its legacy (inheritance vs composition)
    * ISP: Interface segregation principle: An interface is exposing only useful resource to the client
    * DIP: Dependency inversion principle: High level modules do not depend on low level module. Both should depend on abstractions.

XP practices come back into play more and more. To develop application with quality, you mostly find:
* Pair programming: 2 developers code together in order to achieve a feature
* Mob Programming: N developers code together to achieve a feature
* TDD: Test Driven Development. Guide your development with Step by step test that helps you build your application
* ATDD: Acceptance TDD: Starts with an acceptance (i.e sometimes user) tests to keep in mind the end result you expect, and build your algorithm steps by steps using TDD.
* Code review: before merging code, you make sure the code is correct regarding your team shared practices (code readability, testability, naming convention...)
* Sources management tool: Do not even think of developing without Git (or equivalent... SVN, CSV... Kidding ;)). That is a great tool to centralize the code bases with tagging, commit, branch management...
    * Sources repositories is the GCP service to manage your source code. It can be sync with Github if you prefer to keep your sources there.
* CI/CD : To shorten the feedback loop of your development, and to send a story in production quickly, you need to create a Continuous Integration or Deployment pipeline. This pipeline will run tests automatically and deploy application on the environment.
    * Cloud Build is the GCP service to let you create your CI/CD pipeline
* And even more, but I think those are the main ones. 

#### Debugging and profiling code

Debugging an application is part of the developer life. When an error occurs, and it will, you need to be able to debug the application. You can not debug in production, as it will stop the application for the end users, not possible ^^. But you could reproduce the bug locally if possible. If not, you can use the Debugger tool of GCP to take hot snapshot of your application, giving you the ability to understand what happens in your code.

Profiling code helps to understand where you have low performace. Does a method take more times than others ? How long before ending the code. Great profiling tool is very important to understand what causes a latency for a client. GCP provides Profiling, a tool to profile your application on production. If you do not have such tool, you endup monitoring your application with timer inside your application, which makes your profiling harder to analyse.

--> TODO : Labs on stackdriver debugger and/or monitoring

### 2.3 Testing. Considerations include:

#### Unit testing

Unit tests are very fast, specific test of your application. Their purpose are to test a unit of functionality. They can span multiple classes, as long as it is still testing the same unit of functionality.

In a Unit test, you can mock dependencies to external services, like calling an API or something.

A unit test must not leave your memory or go through the network in order to stay fast, and independent from the environment.

When developing using the DDD patterns, you have to unit test a lot your domain layer. This is critical, in order to quickly adapt and resolve in case of a bug after a code change... 

You really need to rely a lot on unit tests, as integration tests are much slower, and does not gives you a feedback as fast as possible.

#### Integration testing

Integration tests are tests that test a group of functionality together. They are usually slower, as you can reach a database, or simulate an API call... those tests are expensive to run and must be considered carefully. Of course, you need integration test in your application, but you need less of them than Unit tests. 

#### Performance testing

Performance testing, a non-functional testing technique performed to determine the system parameters in terms of responsiveness and stability under various workload. Performance testing measures the quality attributes of the system, such as scalability, reliability and resource usage.

To have an efficient performance test session, you need to know first what metrics you want to capture. Are you checking throughput, latency, resiliency, Availability ? 

You find different subsets of performance testing, like: 
* Load testing: Gradually improve the charge to see how the application handles the load.
* Stress testing: It is performed to find the upper limit capacity of the system and also to determine how the system performs if the current load goes well above the expected maximum.
* Soak testing: Soak Testing also known as endurance testing, is performed to determine the system parameters under continuous expected load. During soak tests the parameters such as memory utilization is monitored to detect memory leaks or other performance issues. The main aim is to discover the system's performance under sustained use.
* Spike testing: Spike testing is performed by increasing the number of users suddenly by a very large amount and measuring the performance of the system. The main aim is to determine whether the system will be able to sustain the workload.

#### Load testing

Load testing - It is the simplest form of testing conducted to understand the behaviour of the system under a specific load. Load testing will result in measuring important business critical transactions and load on the database, application server, etc., are also monitored.

### 2.4 Building. Considerations include:

#### Source control management

A source control management is mandatory for any software development. Even if you are a single developer, it is mandatory. When working in teams, it helps the team focusing on development, and provides features like branching, tagging and merging to keep track of the source code. 

It also provides history to go back to a previous state if needed.

GCP provides Sources Repositories, an online repository, like Github, to store team source code. It is based on Git. Source repositories is important when using Monitoring, Profiling and Debugging of application hosted on GCP. It is also useful to trigger build deployments with Cloud build, when a new branch is pushed for instance. 

A Source repositories can be sync with GitHub or BitBucket if you wish to store your source code in another place.

#### Creating secure container images from code

When you run application on GCP, you will need to create a Docker image (if you deploy on AppEngine, you won't need Docker). This Docker image is used when running the application on GKE cluster, or on Cloud Run, or even on Compute Engine (by checking : run with an image).

So when you need to provide your own Docker image, you create a `Dockerfile`. Docker works by layering the content of the `Dockerfile` to favor reusability. You base your image on top of another one. For instance, to run a Spring Boot application, you could an image containing a JRE installed. If you prefer to create your own image, you can have an alpine-linux as base image, and then install only the tool you need...

Anyway, once the Dockerfile is created, it can be run by a runtimeContainer. Docker is also a runtimecontainer. So you can run your image using 
```shell script
docker build -t gcr.io/PROJECT_NAME/my-image:latest .
docker run gcr.io/PROJECT_NAME/my-image:latest
```

Choosing a base image must be considered carefully. I recommend:
* Choose only an official image as a base image, to make sure you do not have unknown vulnerabilities
* Favor official images also to make sure it will be maintained and evolve over time
* Try to keep your image as small as possible. So rely only on what is strictly necessary to run... It is not useful to import more than needed, as you might have more vulnerabilities because of that

And to ensure the security of your image, you can security scanner, a GCP service that scans Containers Registry and Artifact Registry.

#### Developing a continuous integration pipeline using services (e.g., Cloud Build, Container Registry) that construct deployment artifacts

To develop a Continuous integration/deployment pipelines, you can use Cloud Build. Cloud Build is a service like CircleCI or TravisCI, providing CI as a service. 

You can configure your CI pipeline in a `cloudbuild.yaml` file that respects the Cloud Build format (https://cloud.google.com/cloud-build/docs/build-config?hl=en). You define `steps` that are the task to execute. Tasks are executed in a Docker container. You can specify the Docker image (`name`) for the step depending on the task you have to perform (like maven build, docker push, yarn...).

Every step shares the same volumes, `/workspace`. So you can build your project in one step and build the Docker image in the other... If you need more than the default volumes, examples, you want to persist the maven local repositories as you need to perform several maven build in the pipeline, you can define your own `volumes`, Cloud Build will persist them. 

By default, the execution is linear, which means steps are executed after one another, in the order defined in the `cloudbuild.yaml` file. If you need parallelism, you can use `waitFor` with `id` to say, my step will wait only for the step `id` to finish. So here starts a parallel pipeline.

To push images on Containers registry, you define a custom step executing a `docker push`, or you can use the `images` statement (at the same level as `steps`). At the end of the pipeline, Cloud build will automatically push images to the specified hub. 

The purpose of the pipeline is to build your project, executing unit and integration test and then build your artifact. You can go further by executing end-to-end tests after your application has been deployed when you are not deploying to production for instance... It is up to you.

To make sure you have a full CI pipeline, you need to use Cloud Trigger (and Source repositories, it is easier). This combination will trigger a build every time a push is made on a branch of your application (on a branch, or on anything you specified in Cloud Trigger). You can use `substitutions` variable in your `cloudbuild.yaml` file to make the most of it. Like using a particular namespace for kube, or a specific service for cloud-run, or running your application with specific EMV variable to connect to a different database depending on if you are deploying staging or production...

* CloudBuild does not support conditional steps yet. So you need to perform that manually with a shell `if`... Not great
* CloudBuild does not support caching automatically. If you want a cache (like the maven local repository, you need to define it yourself...)

Here an example of a complete `cloudbuild.yaml` file:
```yaml
steps:
  - id: 'dockerize-project'
    name: gcr.io/cloud-builders/docker
    dir: backend
    args: [ 'build',
            '-t', 'gcr.io/$PROJECT_ID/backend:$SHORT_SHA',
            '-t', 'gcr.io/$PROJECT_ID/backend:latest',
            '.' ]

  - id: 'push-to-cloud-registry'
    name: gcr.io/cloud-builders/docker
    args: [ 'push', 'gcr.io/$PROJECT_ID/backend:$SHORT_SHA' ]

  - id: 'deploy-cloud-run'
    name: gcr.io/cloud-builders/gcloud
    dir: backend
    entrypoint: bash
    args:
      - '-c'
      - |
        apt-get update
        apt-get install -qq -y gettext
        export PROJECT_ID=$PROJECT_ID
        export IMAGE_VERSION=$SHORT_SHA
        envsubst < cloudrun-backend.yaml > cloudrun-backend_with_env.yaml
        gcloud beta run services replace cloudrun-backend_with_env.yaml \
                  --platform=managed --region=europe-west1
        gcloud run services add-iam-policy-binding application-backend \
                  --platform=managed --region=europe-west1 \
                  --member="allUsers" --role="roles/run.invoker"


images:
  - 'gcr.io/$PROJECT_ID/backend:$SHORT_SHA'
  - 'gcr.io/$PROJECT_ID/backend:latest'
``` 

#### Reviewing and improving continuous integration pipeline efficiency

The quicker the pipeline is, the sooner you get a feedback. It is important to manage efficiently your pipeline:
* Execute in parallel what can be
* Make sure you log enough information to understand what went wrong
* Run your unit and integration tests at least
* Use cache if needed to avoid downloading many times the same resources (maven/yarn dependencies)
* Use substitutions variables to have a conditional build and deploying within the same project on different services

## Section 3: Deploying applications

### 3.1 Recommend appropriate deployment strategies using the appropriate tools (e.g., Cloud Build, Spinnaker, Tekton, Anthos Configuration Manager) for the target compute environment (e.g., Compute Engine, Google Kubernetes Engine). Considerations include:

* Cloud Build: A GCP service that provides steps to build, containerize and even deploy your applications. Everything is "low-level" as you can do anything you want, but you might need to implement everything yourself (like canary or blue/green deployment...)
* Spinnaker: Opensource, multi-cloud continuous delivery platform that helps releasing software changes. Supported by Netflix, it enables, through some configuration (Application, cluster, server-groups, load balancer, firewall, deployment strategies...) to deploy your application (based on a trigger, like push to a container registry). It gives the possibility to deploy regarding your deployment strategy: canary, blue/green and rolling updates. 
    * Labs: https://www.qwiklabs.com/focuses/552?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&parent=catalog&search_id=8680538
    * To work properly, Spinnaker needs:
        * a dedicated service account with restricted access (only to `storage.admin` and `pubsub.subscriber`)
        * To trigger a build, Spinnaker reads messages from PubSub
        * It deploys the application in a GKE cluster
* Tekton: Tekton is a cloud native continuous integration and delivery (CI/CD) solution. It allows developers to build, test, and deploy across cloud providers and on-premise systems. Apparently, like Spinnaker, it lets build, through abstractions, your CI/CD pipeline to deploy regarding your deployment strategies: canary, blue/green and rolling updates. Tekton seems to be specialized in kubernetes deployment.
* Anthos Configuration manager: Is a service provided by GCP to manage multi-cloud and on-premises environment. You can enforce security policies or others by using Anthos, that will replicate the change you made on GCP to all others platforms.

#### Blue/green deployments
* In compute engine, use DNS switch to migrate requests from one load balancer to another
* In kubernetes, configure your service to route to the new pods using labels
      * Simple configuration change
* In app Engine or Cloud run, use the Traffic splitting feature (100% Blue 0% Green -> 0% Blue 100% Green )

#### Traffic-splitting deployments
* In compute engine, configure the load balancer to enable Traffic splitting
* In kubernetes, configure traffic splitting in deployment file
* In appEngine and CloudRun, enables by default. Just specify the value to split (20-80, 50-50...)

#### Rolling deployments
* In compute engine, change the instance template (if managed by an instance group)
* In kubernetes, Just change the image version, kube will do the rest
* In appEngine, CloudRun: already provided by default

#### Canary deployments
* In compute engine, create a new instance group and add it as a backend in your Loadbalancer
* In kubernetes, create a pod with the same labels as the existing pods. the service will automatically route a portion of requests to it
* In App Engine or CloudRun, use the Traffic splitting feature, and split traffic like 20-80, or 50-50...

Basically, for some deployment strategies, you can rely on GCP default tools, it works well. But for some others, you might need the support of a CD tool, like Spinnaker, Tekton or Anthos. The tool you choose will depend on the use case.

### 3.2 Deploying applications and services on Compute Engine. Considerations include:

#### Installing an application into a virtual machine (VM)

When using a Compute Engine, you have a lot of possibilities to install your application. You need to run or execute your specific command (like using `apt-get`, or deploying using Ansible...).

Then, once the application runs on your compute engine, you need to configure the accessibility to your application. For these, you need to configure the Firewall rule to make sure the VM can be accessed from the outside.

With a Firewall rule, You can then add a LoadBalancer.

But the most efficient way to configure an application is to configure an Instance Managed Group. To do so:
* Define an instance template, that will execute a startup script to install your application
* Create an instance managed group (even if with only 1 instance) to have the possibilities to add more VM in case of peak loads.
* Configure a LoadBalancer to dispatch request to the groups
    * Have a Health check to know if your instance is healthy
    
If you need to install your application manually first, chances are you will need to log into the instance. To do so, you can use the SSH button provided by GCP, or you can also execute SSH from your computer. If you do so, you will need to configure your SSH public key as an authorized public key to connect to your instance (either on project level or VM level)

#### Bootstrapping applications

To bootstrap an application, use an Instance template. You can create it from scratch, by specifying any attributes you might need, like boot disk size, disk size, network, network tags (in combination with firewall rules).

Or, you could also create a template from a running instance, very handy when you are trying to see of your application will work in such configuration.

````shell script
gcloud compute instance-templates create example-template-custom \
    --machine-type e2-standard-4 \
    --image-family debian-9 \
    --image-project debian-cloud \
    --boot-disk-size 250GB
````

#### Managing service accounts for VMs

As always, you need to ensure the principles of least privileges. To do so when using a Compute engine instances, you can configure the service account that will be using the VM. If your VM doesn't need access to a GCP resources, the best way to ensure security is to create a service account with no specific roles.

You can also set a specific scopes that will be targeted by the instance... I think a good practice is to create a service account with restricted IAM roles... But the scopes can also limit the different request you can perform...

#### Exporting application logs and metrics

An instance records all audit logs. Audit logs are available in the Logs Viewer. A compute engine instances logs 3 types of logs:
* Admin activity logs: Modification of compute engine metadata or resource. Any API call that creates, deletes, updates or modifies a resource.
* System event logs: system maintenance on Compute engine resources. Driven by the Google System, not you.
* Data access logs: Read-only operation on Compute engine resources, like get, list... It logs ADMIN_READ logs, and DATA_READ or DATA_WRITE logs, unlike Cloud Spanner, Storage or BigTable.
* Policy Denied audit logs: logs when a GCP service denies access to a user or service account

With Stackdriver, you can also have a centralized view and create dashboards about your compute engine resources. For that, you need to install stackdriver agents on your Compute engine instance:
```shell script
curl -sSO https://dl.google.com/cloudagents/add-monitoring-agent-repo.sh
sudo bash add-monitoring-agent-repo.sh
sudo apt-get update
sudo apt-get install stackdriver-agent
sudo service stackdriver-agent start

curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
sudo apt-get update
sudo apt-get install google-fluentd
sudo apt-get install google-fluentd-catch-all-config-structured
sudo service google-fluentd start
```

These agents extract metrics from your Compute Engine, like CPU usage (even if CPU is available with no agent), memory footprint and other information. You can create dashboard in StackDriver to monitor your VM and set up some uptime check and alert policy based on some metrics (CPU usage and other...). You can also create alert policy based on logs, like if your VM has a deny access to a service, or if you have an error log, or a change in IAM policy..

#### Managing Compute Engine VM images and binaries

To create a compute engine, you need to specify the base image you want to use. Some images are publicly available and install the basic OS (like debian, CentOS...). The images list is available in the "Compute Engine" menu of the GCP console.

Most of the times, this might be enough. But you can also provide your own image to be the base of your application. You can create new image based on an existing disk that has been set by a Compute Engine instance. 

Let's say you always want to have the same base image... You can have a template that runs commands like `sudo apt-get...` but in this case, a new instance might not have the exact same configuration as the old ones... Pretty risky. A solution is to create a base image on an existing disk, to reuse that image in the instance template. This way, you make sure the new instance that will created will rely on the exact same base as the others running.

LABS: 
* https://www.qwiklabs.com/focuses/611?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&parent=catalog&search_id=8708397
    * Autoscaling based on a custom metrics, sent to stackdriver by an application executed inside a Compute Engine instance.
    * Startup scripts for templates are stored in Cloud Storage. When creating an instance, it will first download and execute startup script
    * Instance groups can be configured to respond to metrics to autoscale the group
* https://www.qwiklabs.com/quests/81?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&search_id=8708394
* https://cloud.google.com/monitoring/quickstart-lamp
    * Create a compute engine instance installing an apache server
    * Install the stackdriver agents for logging and monitoring (works also with AWS)
    * Create custom metrics for your VM
    * Create uptime check with alert policy (email, pubsub...)
    * Create your own custom dashboard with graph and metrics (CPU, Bytes received...)
* Create an image based on an image disk


### 3.3 Deploying applications and services to Google Kubernetes Engine (GKE). Considerations include:

Labs: 
* https://www.qwiklabs.com/focuses/2771?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&parent=catalog&search_id=8750898
* https://www.qwiklabs.com/quests/24?catalog_rank=%7B%22rank%22%3A1%2C%22num_filters%22%3A0%2C%22has_search%22%3Atrue%7D&search_id=8750906

#### Deploying a containerized application to GKE
To connect kubernetes to the GKE cluster, you need to run an authentication command:
```shell script
gcloud container clusters get-credentials quiz-cluster --zone us-central1-b --project <Project-ID>
```

Once you are connected to the GKE cluster, you can run `kubernetes` command to deploy your application in the cluster.
With Kubernetes, you have different options to deploy an application. You can either use:
* `kubectl create -f ./frontend-deployment.yaml` Or `kubectl apply -f ./frontend-deployment.yaml`. This command reads your description file and make sure your cluster and application are configured like the description file. It can update your cluster by only applying and executing the command to go from the current state to the desired state.
* Or you can create and manage your cluster manually with some commands to create what you need

```shell script
kubectl get nodes
> Get all nodes in the default namespace

kubectl create deployment kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1
> Create a deployment called kubernetes-bootcamp and runs the image grc.io in containers
> By default, the application runs in a single instance (a single replicas ?)

kubectl get deployments
> Get all deployments in the default namespace

kubectl get pods
> List all pods in the cluster in the default namespace
> option -l to filter by label

kubectl describe pods
> Describe all the pods by giving a lot of information like 
>  * IP address (for inside the cluster)
>  * The containers currently running
>  * The events logs to trace the pod state

kubectl logs <POD_NAME>
> Displays all logs (all data send to STDOUT)

kubectl exec $POD_NAME env
> Runs the command env inside the POD identified by its name

kubectl exec $POD_NAME bash
> Runs a bach in your Pod. You can then execute any command of your choice (available in your pod)

kubectl get services
> List the services in the default namespace

kubectl expose deployment/kubernetes-bootcamp --type="NodePort" --port 8080
> Exposes the deployment kubernetes-bootcamp with a NodePort services for a Node exposing the application with the port 8080

kubectl describe services/kubernetes-bootcamp
> Describe the service

kubectl label pod $POD_NAME app=v1
> Apply new label to the pod
> Pod can be changed by service or deployment

kubectl delete service -l run=kubernetes-bootcamp
> Delete all services matching the label run=...

kubectl get rs
> Get the replicasset of the cluster

kubectl scale deployments/kubernetes-bootcamp --replicas=4
> Increase/decrease the number of Pods up to 4 for the kubernetes-bootcamp deployment.

kubectl set image deployments/kubernetes-bootcamp kubernetes-bootcamp=jocatalin/kubernetes-bootcamp:v2
> Change the image of the deployment to start a rolling update

kubectl rollout status deployments/kubernetes-bootcamp
> Check if the rollout is fully performed (enables to wait in a CI/CD pipeline before movign forward)

kubectl rollout undo deployments/kubernetes-bootcamp
> In case of error during the deployment of a new version, you can rollback to the previous state

```

#### Managing Kubernetes RBAC and Google Cloud IAM relationships

##### Kubernetes RBAC 
Kubernetes Roles Based Access Control is the control system kubernetes relies on when it comes to User management. In order to restrict user access inside the cluster.

The RBAC API is based on 4 objects:
* Role
    * A set of permissions within a particular namespace.
* ClusterRole
    * A set of permissions across all namespaces
* RoleBinding
    * Bind a user/group or service account to a Role for a particular namespace, or bind it to a ClusterRole for application within your namespace
* ClusterRoleBinding
    * Bind a user/group or service account to a ClusterRole, across all the namespaces. 

##### IAM roles

In GCP, you can manage user access to a project resources by granting roles. Roles are a set of permissions that allow the user to perform a specific actions with it belongs to a particular roles.

##### IAM + RBAC

With GKE, instead of having 2 authentications system, RBAC and IAM, IAM and RBAC are integrated together.
To authenticate to a GKE cluster, use the command: 
```shell script
gcloud container clusters get-credentials quiz-cluster --zone us-central1-b --project <Project-ID>
```
> Please note any user needs to have granted the role `container.clusterViewer` that gives the ability to at least connect to a cluster. You then need to ask for other permission to perform actions in the cluster.

You can bind cluster/roles to different kind of users. A Kind is the name RBAC understands knowing what kind of users it expects to grant the roles. Coupled with IAM, the same Kind can mean different things:
* Kind User: 
    * Google Cloud registered email address
    * IAM service account
* ServiceAccount: A kubernetes service account
* Group: Email address of a Google Group that is itself the member of the Google Group gke-security-groups@yourdomain.com

To create a new role binding:
```shell script
gcloud iam service-accounts describe service-account-email
> this outputs the unique-id of the service account

kubectl create clusterrolebinding clusterrolebinding-name \
  --clusterrole cluster-admin \
  --user unique-id
> Bind the clusterRole cluster-admin to the unique-id user
```

#### Configuring Kubernetes namespaces

Namespaces are really important when multiple users and teams are working on the same cluster. It allows to group resource inside a namespace. A name of a resource needs to be unique inside a namespace, but not across. 

It enables also to divide the cluster per users and define resource quotas.
```
kubectl config set-context --current --namespace=<insert-namespace-name-here>
> Specify the default namespace you use in your cluster
```

#### Defining workload specifications (e.g., resource requirements)

It is considered a bad practice to run Kube containers without any limits or request restrictions. 
```shell script
spec.containers[].resources.limits.cpu
spec.containers[].resources.limits.memory
spec.containers[].resources.requests.cpu
spec.containers[].resources.requests.memory
```

If you apply a limit, then Kubelet will enforce this limitation, and make sure the container does not consume more. If you apply a request, then Kubelet will let the container use more memory if the Node can provides more resources.

The most common resource type you can put limitation on are: CPU and Memory (RAM).

* CPU: represents a unit of processing and are specified in units of Kubernetes units. In the Cloud, 1 CPU is equivalent to 1vCPU/Core.
    * You can set value below 1. like 0.1 to have 100m (one hundred milliscpu) for your container
* Memory: in unit of bytes. You can set value like 64Mi (2^64 bytes).

As a Pod is the deployable unit, to have a full meaning, it is important to talk about Pod requests/limits that is the sum of all resources of its container.
 
Example of configuration for 2 containers in a single pods
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
spec:
  containers:
  - name: app
    image: images.my-company.example/app:v4
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
  - name: log-aggregator
    image: images.my-company.example/log-aggregator:v6
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

#### Building a container image using Cloud Build

To build a container image Container registry, you can use Cloud Build. This service provides a way to easily execute a `Dockerfile` file and send the created image to Container Registry.

Here is the command to create an image from a Dockerfile:
```shell script
gcloud builds submit -t gcr.io/$DEVSHELL_PROJECT_ID/quiz-frontend ./frontend/
```
> `-t` is the image tag. If you want the image to be uploaded in your GCP project, provide your GCP_PROJECT_ID in the command line.
>   * `gcr.io` is the URL of Container Registry.
> The last parameter if the folder containing the Dockerfile file

#### Configuring application accessibility to user traffic and other services

To expose the application to user, you need to create **Service**. A service exposes a deployment in 4 different ways:
* ClusterIP: Exposes the service on an internal IP in the cluster. Is not reachable from the outside, only inside the cluster
* NodePort: Exposes the service on the same port of each selected Node in the cluster using NAT. Makes the service accessible from outside the cluster using <NodeIp>:<NodePort>. Superset of ClusterIP.
* LoadBalancer: Creates an external LoadBalancer in the current cloud (if supported, like GCP) and assigns a fixed, external IP to the service. Superset of NodePost
* ExternalName: Exposes the service using an arbitrary name (specified by the externalName in the spec) return the CNAME record with the name.

With GKE, when using the `LoadBalancer`, it creates an external HTTP Load Balancer that exposes your deployment to the outside world with an IP address provided by Google.

#### Managing container lifecycle

A Pod lifecycle is as simple as this:
* Pending phase: Is waiting for kube to start it. It is either in the scheduling queue, or starting its containers
* Running phase
    * All Pods in running phase are managed by kubelet and restarted if the pod is not matching the application requirements (meet the correct number of replicas for instance)
* Succeeded or Failed phases depending on whether any container terminated in failure in the Pod

A Pod is an ephemeral resource, that can be disposed at any time. If a Pod needs to migrate to a new Node, the current Pod is deleted and a new one is created. It is important to design them to be stateless, or with volumes configuration if you need.

Pod runs Containers. Container states are:
* Waiting: It is running operations it requires in order to complete start up (pulling container image, applying secret).
* Running: It is executing without issues
* Terminated: After execution, it ran to completion or failed for some reasons. Querying a Pod with Kubectl you can see the exit code and finish time for that container's period execution.

You can create Hook on container phases:
* PostStart: Hook executed after the Container is created. But, there is no guarantee the hook will run before the Container ENTRYPOINT. No parameters are passed to the handler.
* PreStop: Hook called before a container is terminated due to an API request, or management event such as liveness probe failure, preemption, resource contention and others... No parameters are passed to the handler

#### Define Kubernetes resources and configurations

Kubernetes is based on:
* **Nodes**, that are the workers, either physical or virtual. When starting a GKE cluster, the Nodes are the Compute engine instances created
* **Pods**, that are the atomic unit of deployment. They represent a group of one or more application. Containers in a POD shares same IP address and port space. They run in the same context on the same Node.
    * When creating a deployment, Kube crete a PODS with containers.
    * containers in a Pods share storage as Volumes, Networking, and information about how to run each container.
    * By default, a Pod is private. It can not be accessed from the outside world.
* As a Pod is an ephemeral instance, it can be restarted. Sometimes, your container can tell to kubelet if it is still okay. Those are the **Probes**:
    * Liveness probe: Whether a container is running. If this probe fails, kubelet kills the container, and the container is subjected to restart policy. Without liveness probe, the default State is success
    * Readiness probe: Whether the container can handle requests. If the readiness probe fails, the endpoints controller removes the POD's IP address from endpoints of all Services that match the pod.
    * startupProbe: Whether the application within the container is started. If this probe fails, the containers is subjected to restart policy.
* Probes have different implementation:
    * ExecAction: Executes the specified command inside the container (a shell script). Success if the command response code is 0.
    * TcpSocketAction: performs a TCP check againts the Pod's IP address. Success if the port is open
    * HttpGetAction: Performs a Get request against the Pod's IP address on a specified port and path. Success if response code is >= 200 and < 400
* **RestartPolicy**:  A container restart policy indicates what are the conditions to restart a container. Possible values are Always (default), OnFailure and Never. It applies to all containers within the POD.
* **Services**: Abstraction which defines a logical set of Pods and a policy by which to access them. It enables a loose coupling between dependent Pods. Indeed, if your app1 depends on app2, and app2 is deployed across multiple pods, you can't refer to the app2 IP addresses to communicate. Use a Service to expose app2 through a single IP address, and the service will dispatch the request according the policy and pods states.
    * ClusterIP: Exposes the service on an internal IP in the cluster. Is not reachable from the outside, only the cluster
    * NodePort: Exposes the service on the same port of each selected Node in the cluster using NAT. Makes the service accessible from outside the cluster using <NodeIp>:<NodePort>. Superset of ClusterIP.
    * LoadBalancer: Creates an external LoadBalancer in the current cloud (if supported, like GCP) and assigns a fixed, external IP to the service. Superset of NodePort
    * ExternalName: Exposes the service using an arbitrary name (specified by the externalName in the spec) return the CNAME record with the name.
    * To match a set of Pods, services use Labels and selectors. Labels are key/value pair attached to objects.
* **Scaling**: the purpose of kubernetes is to provide autoscaling behavior for your pods to make sure your application can deliver and handle request even if there is a peak load.
* **ReplicasSet**: the objects that enables the autoscaling.
* **RollingUpdates**: Updates your application in a transparent way for your users, by updating the application pod after pod.
    * It requires more than 1 instance in order to work.
    * You can also configure the number/percentage of pods unavailable during the update.     
    
### 3.4 Deploying a Cloud Function. Considerations include:

Cloud functions are the most serverless solution in GCP. You just to write codes in one of the CloudFunctions supported languages and versions:
* Node.js Runtime
* Python Runtime
* Go Runtime
* Java Runtime
* .NET Runtime
* Ruby Runtime

With the proper dependencies, you can then have a Function executed based on different triggers.

Be careful with Functions. Like Cloud Run, the CPU is allocated only when the corresponding event is received, and stops immediatly after the function completion. Do not start async task without waiting for its completion, or it might never be completed.

#### Cloud Functions that are triggered via an event from Google Cloud services (e.g., Pub/Sub, Cloud Storage objects)

Cloud functions can be triggered with internal event in GCP. Among this event, you can have a PubSub message received in a Topic, or on a Cloud Storage objects.

Example for a PubSub Topic:
```shell script
# create a topic
gcloud pubsub topics create YOUR_TOPIC_NAME
# Deploy the function
gcloud functions deploy java-pubsub-function \
--entry-point functions.HelloPubSub \
--runtime java11 \
--memory 512MB \
--trigger-topic YOUR_TOPIC_NAME
# publish a message
gcloud pubsub topics publish YOUR_TOPIC_NAME --message YOUR_NAME
```

When you want to respond to an event on a bucket:
* google.storage.object.finalize (default): when an object is successfully written to Storage
* google.storage.object.delete: When the object is deleted, very handy to manage non-versioning bucket. Works also if a file is overriden
* google.storage.object.archive: Only used in versioning bucket. Triggered when an old version is archived
* google.storage.object.metadataUpdate: update when objects metadata are updated

You can configure a Function to listen for a specific Bucket event.
> Note: Cloud Functions can only be triggered by Cloud Storage buckets in the same Google Cloud Platform project.

Under the hood, the event is propagated to the Function using PubSub. The JSON message received from PubSub for a Bucket event is structured and gives you a lot of metadata (but you not have the file in the message).

Here is an example:
```shell script
# create a bucket
gsutil mb gs://YOUR_TRIGGER_BUCKET_NAME
# deploy the function to be triggered for google.storage.object.finalize event
gcloud functions deploy java-gcs-function \
--entry-point functions.HelloGcs \
--runtime java11 \
--memory 512MB \
--trigger-resource YOUR_TRIGGER_BUCKET_NAME \
--trigger-event google.storage.object.finalize
# just upload a file to your bucket
gsutil cp gcf-test.txt gs://YOUR_TRIGGER_BUCKET_NAME
```

#### Cloud Functions that are invoked via HTTP

Cloud Functions can ba triggered by an external event like an HTTP request. You can create one function that will respond to one specific endpoints for your application.

I'd recommend not developing real applications with many endpoints split on several Cloud Functions, but it can be handy in some CRUD, administrative operations.

```shell script
# Deploy a function (your code is responsible to know what request to handle
gcloud functions deploy FUNCTION_NAME --runtime nodejs10 --trigger-http --allow-unauthenticated
# Trigger the call
curl -X POST "https://YOUR_REGION-YOUR_PROJECT_ID.cloudfunctions.net/FUNCTION_NAME" -H "Content-Type:application/json" --data '{"name":"Keyboard Cat"}'
```

> Note here is `--allow-unauthenticated` which indicates the Function is publicly accessible. It is not always the case.

#### Securing Cloud Functions

To secure a Cloud Function, you can configure identity-based or network based access control.

With Identity-based access control you can restrict the Function API for:
* developer: creating, updating or deleting a Cloud Function
* User: Restrict function invocation.

```shell script
gcloud functions add-iam-policy-binding FUNCTION_NAME \
  --member=MEMBER_TYPE \
  --role=ROLE
```

Besides, there is a lot of possibilities to authenticate someone using your Functions:
* Developers (function invocation based on IAM roles)
* Function-to-function (using dedicated service account with proper IAM roles to invoke another function)
* End users:
    * using Google Sign-in ()
    * using Firebase token (with a verification made by the firebase admin SDK)
        * Beware of CORS configuration when authenticating the user on a different host name. You might need to open your function publicly, or using cloud endpoint 
* API Keys


With network-based access control, you can control over the network ingress and egress to and from your functions.

Lastly, you also need to provide a dedicated service account for your Cloud Function (like for any other services running on GCP) to make sure the function does not have access to unwanted resources (like a database).


### 3.5 Using service accounts. Considerations include:

#### Creating a service account according to the principle of least privilege

Service accounts are used to authenticate anything that is not a human (a service). You can find service Account on GCE instances, GKE instances and PODS, Cloud Run, AppEngine and Cloud Functions. 

The service account is made to authenticate service to service (like two instances talking together), or a service talking to a Database.

The principle of least privilege ensured your service will not have unnecessary access to others services. By default, your instances run with a default account (one for each kind of runners) with the role Editor. Very handy when developing, could be dangerous in production. 

#### Downloading and using a service account private key file

To be a service account, you need to download and use its private key. To download it, do :
```shell script
gcloud iam service-accounts keys create ~/key.json \
  --iam-account sa-name@project-id.iam.gserviceaccount.com
```

The key needs to be created. Once created, it can not be retrieved, you will need to create a new one.

## Section 4: Integrating Google Cloud services

### 4.1 Integrating an application with data and storage services. Considerations include:

#### Read/write data to/from various databases (e.g., SQL)

Reading/Writing from various SQL databases is done by executing an SQL query. The most basic thing is the SQL query. To do that, you first need to establish a connection with the database (URL, USER and PASSWORD).

* SELECT query are used to read data.
* INSERT/UPDATE/DELETE are used to write data

Nowadays, most framework uses an ORM layer so that the object are mapped automatically into a Relational Database. The most famous one is hibernate, and it is also provided by Spring for a Java Application.

But under the hood, the ORM is simply executing SQL queries.

You can also use a Document oriented databases, like MongoDB, or a Graph databases, like Neo4J... Those store data differently. Some allow SQL lite query, others only from API call...

#### Connecting to a data store (e.g., Cloud SQL, Cloud Spanner, Firestore, Cloud Bigtable)

##### Cloud SQL

Cloud SQL is the SQL data store provided by Google. To connect to it, you have different possibilities:
* How to connect: 
    * Internal, VPC only (private) IP address
    * External Public IP address
* How to authorize: 
    * Cloud SQL Proxy and Cloud SQL language connectors: IAM based access
    * Self-managed SSL/TLS certificates: only connections based on specific public keys
    * Authorize networks: authorized list of IP addresses
* How to authenticate:
    * Native database authentication: username/password set in the database engine
    
Of course, the recommendations are:
* Prefer Private address
* If not possible, use SSL/TLS certificate
* Configure wisely your network if you open your database
* If you host your application on premise and the database on GCP, try using Cloud SQL proxy with a private address for the database. The proxy will handle the connection to your private Cloud SQL instance.

Example of sql proxy usage:
```shell script
./cloud_sql_proxy -instances=<INSTANCE_CONNECTION_NAME>=tcp:3306
```

Spring cloug gcp provides way to communicate with the Cloud SQL instance, by using properties.
    
##### Cloud Spanner

GCP provides different supports for various technologies. To connect to Spanner, you can one of the libs provided by Google, or you can also use the `gcloud` tool. 

Authentication and Authorization are managed with OAuth2. You can configure which user has access to what using IAM roles and assigning users to a database. You have different levels of permissions:
* Project level: impact all Spanner instances
* Instance level: impact all databases in the Spanner instance
* Database level: impact only a specific database in a specific spanner instance.

##### Firestore

Once again, GCP provides support for various technologies. To connect to a Firestore database, you have to use IAM users and roles. You can define specific roles for a IAM user. Besides, the IAM is granted roles to write or read data in the application. But careful, datastore does not enforce restriction on specific entities for specific users. The access granted to a user are granted for all Firestore in Datastore mode. Your application is responsible for ensuring user have access to the entity or the data it requests.

It is possible to do that with Firestore in Native mode using its custom RBAC.   

##### Cloud Bigtable 

BigTable supports the HBase API. To connect to BigTable, you need to create a Connection object, and share it across your thread in your application.

You can provide project information in 2 ways to connect to BigTable:
* include settings in code
* Use the hbase-site.xml file

In both cases, you need to provide:
* the PROJECT_ID
* the INSTANCE_ID
* the APP_PROFILE_ID (only if using app profiles)

To connect, it requires a user or a service account. You can configure the user access at project, instance and table levels.

You can't grant access to AllUsers or AllAuthenticatedUsers, it is forbidden.

##### Notes
It seems to me that only Cloud SQL works differently from the others storages system. Apart from CloudSQL, they are integrated with IAM roles.

Cloud SQL uses a proxy to securely handle the connection, the others uses natively a secured protocol (SSL).
Datastore/firestore does not provide easy way to manage rights for a certain entity. 
CloudSpanner and Cloud BigTable supports fine-grained roles for their object (databases, tables)
Cloud SQL supports fine-grained access using MySQL users and roles management.

#### Writing an application that publishes/consumes data asynchronously (e.g., from Pub/Sub)

In any system hosting microservices, at some point, you will need to send data asynchronously. There can be different reason:
* Sending an event to notify other system
* Tracing and monitoring, without impacting the end users
* Using the messaging system as a circuit breaker

Any application can publish data to PubSub. This messaging system exposes a REST API callable by any system able to send HTTP requests (anyone). GCP provides different APi for different languages to interact with Cloud PubSub.

As always, you can configure using IAM who can use PubSub:
* managing topics
* publishing to a topic
* Reading from a subscription
* ...

For this use case, the application needs to support background actions, in order to fetch data from a subscription on a regular basis, to perform the action needed when receiving an event.

When reading a message from a subscription, the application must ACK the correct reception of the message (once again, using the PubSub API). 

Also, for some use cases, PubSub can PUSH a request to an endpoint (which can be protected for a TOKEN of a user account). The endpoint has to respond an HTTP Response. If the request is correct, it sends a code 2XX, ACK the message and telling PubSub not to send it again. Or, 4/5XX in case of error. In this case, PubSub will send the message again.

```shell script
gcloud pubsub topics publish my-topic --message="hello" --attribute="origin=gcloud-sample,username=gcp"
```

#### Storing and retrieving objects from Cloud Storage

Once again, use one of the APIs provided by GCP to read and write data from Cloud Storage. You can easily use `gsutil` to read data from Cloud Storage:
```
gsutil cp gs://BUCKET/OBJECT DESTINATION
gsutil cp SOURCE gs://BUCKET/OBJECT
```

### 4.2 Integrating an application with compute services. Considerations include:

#### Implementing service discovery in GKE and Compute Engine

Service discovery is a mechanism to automatically detect and add nodes to a network. This remove the burdens of user configuration of a cluster.

To implement a Service Discovery, you need to access GCP resources metadata (configuration data), for GCE or GKE. These metadata are IPs addresses for instances, or VM name, or a label...

When creating a LoadBalancer for a Managed Instance Group, behind the scene, a service discovery is used to handle VM add or removal automatically. To do that, the LoadBalancer and the Instance groups use Health Check to check if an instance is still alive.

My guess is that many GCP services queries the GCE/GKE metadata to know there IP addresses and being able to redirect properly the request to a running server. And if a VM gets shutdown, the service discovery updates its internal metadata and do not request the stopped VM after.

For GKE, the service discovery is handled by Service, where you can target a set of pods based on their label for instance. 

The service registry can be based on label (like labels applied to a GCE instance, like 'http-server', or 'database', or 'background-tasks'...). These labels can be used to filter more specifically what VMs to put behind a LoadBalancer for instance.

Useful resources: https://cloud.google.com/compute/docs/storing-retrieving-metadata?hl=en

You can query different kinds of metadata:
* at project level: http://metadata.google.internal/computeMetadata/v1/project/
* at Instance level: http://metadata.google.internal/computeMetadata/v1/instance/

Please note:
* for querying metadata using CURL, you absolutely need to add the header `Metadata-Flavor: Google`
* You can't use the X-forwarded-For header 
* When querying metadata, you also get the quotas your project is currently assigned

#### Reading instance metadata to obtain application configuration

* Reading metadata (project level and instance level)
```shell script
gcloud compute project-info describe

gcloud compute instances describe <instance_name> --zone=us-central1-a
# The zone is optional if you set a default zone in your gcloud config
```

* To set a metadata when creating the instance:
```shell script
gcloud compute instances create example-instance \
    --metadata foo=bar
```

* To set a metadata on a running instance:
```shell script
gcloud compute instances add-metadata instance-name \
      --metadata bread=mayo,cheese=cheddar,lettuce=romaine
```

* To remove a metadata
```
gcloud compute instances remove-metadata instance-name \
    --keys lettuce
```
#### Authenticating users by using OAuth2.0 Web Flow and Identity-Aware Proxy

##### OAuth2

OAuth2 is the industry standard protocol for authorization.

A client wishing access to a protected resources will go through a flow to make sure he can access the protected resource:
1. The Client makes a request to the Resource Owner, asking if he could access the resource
2. The Resource Owner responds with an authorization Grant.
3. The Client uses the authorization Grant to make a request to the Authorization Server
4. The Authorization Server responds with an access token
5. The Client requests the Resource Server with the Access token
6. The resource server responds the resource

##### Identity Aware Proxy

Identity Aware Proxy (IAP) is a proxy that can automatically protect your applications against unauthenticated user. It uses the OAuth2 protocol to ensure the user has access to the resources. IAP works well with:
* AppEngine or Cloud Run
* An External Load Balancer
* An internal Load Balancer

It can not protect the user if it knows the direct VM IP:PORT address to communicate with the VM. Also the same for GKE. IAP will also need a correct firewall configuration to access your compute engine instances.

For a user to gain access to a service, it needs to have the IAP-secured Web App User role.

It is not because you used IAP that it means you can not not secure your apps. You always have to make application authorization, in case an attacker bypasses IAP, or IAP is turned off. To do this, you need to check the signed JWT IAP sends you: https://cloud.google.com/iap/docs/concepts-best-practices.

Be careful with caching also, as a cached request can be served to an unauthenticated user. To avoid this, you can split into different domains, and use `Cache-control: private`.

#### Authenticating to Cloud APIs with Workload Identity

Workload identity is the recommended way to access Google Cloud services from application running on GKE.

Google Cloud APIs are protected for unauthenticated users. By default, an application running on a POD uses a Kubernetes service account. This account is different from Google service account. You can configure the Kubernetes Service account to act as a Google service account in order to execute APIs Calls.

To do this securely, Workload identity introduces the concept of workload identity pool, allowing IAM to trust and understand Kubernetes service account.

The mapping is done for kubernetes service account that share a name, a namespace name and a workload identity pool. Which means, if your project is hosting applications on different cluster, if the namespace used across the cluster has the same name, the same GCP service account will be used. This could be inconvenient. When such a use case happens, and you don't want another to have access to a GCP service account, you need to create a new project (because there is only currently one security pool per project).

The advantages if that is the possibility to enforce the principle of least privilege. Create a service account specific for your application, not just for the GKE cluster. 

### 4.3 Integrating Cloud APIs with applications. Considerations include:

#### Enabling a Cloud API

GCP works with APIs. By default, almost all APIs are disabled, which means you can request them. If you want to do so, consider enabling the API first:
```
gcloud services enable cloudbuild.googleapis.com 
```

#### Making API calls using supported options (e.g., Cloud Client Library, REST API or gRPC, APIs Explorer) taking into consideration:
##### Batching requests

Batch API calls to make multiple requests at once. Can be useful for caching offline requests, or for new APIs where you have a lot of data to upload.

To perform a Batch call:
* Send a request to /batch/api_name/api_version.
* Set the content type to `multipart/mixed`. You can have nested HTTP request in the main HTTP request 
* Each HTTP part begins with `Content-Type: application/http`

Request:
```
POST /batch/farm/v1 HTTP/1.1
Authorization: Bearer your_auth_token
Host: www.googleapis.com
Content-Type: multipart/mixed; boundary=batch_foobarbaz
Content-Length: total_content_length

--batch_foobarbaz
Content-Type: application/http
Content-ID: <item1:12930812@barnyard.example.com>

GET /farm/v1/animals/pony

--batch_foobarbaz
Content-Type: application/http
Content-ID: <item2:12930812@barnyard.example.com>

PUT /farm/v1/animals/sheep
Content-Type: application/json
Content-Length: part_content_length
If-Match: "etag/sheep"

{
  "animalName": "sheep",
  "animalAge": "5"
  "peltColor": "green",
}

--batch_foobarbaz
Content-Type: application/http
Content-ID: <item3:12930812@barnyard.example.com>

GET /farm/v1/animals
If-None-Match: "etag/animals"

--batch_foobarbaz--
```

Response:
```
HTTP/1.1 200
Content-Length: response_total_content_length
Content-Type: multipart/mixed; boundary=batch_foobarbaz

--batch_foobarbaz
Content-Type: application/http
Content-ID: <response-item1:12930812@barnyard.example.com>

HTTP/1.1 200 OK
Content-Type application/json
Content-Length: response_part_1_content_length
ETag: "etag/pony"

{
  "kind": "farm#animal",
  "etag": "etag/pony",
  "selfLink": "/farm/v1/animals/pony",
  "animalName": "pony",
  "animalAge": 34,
  "peltColor": "white"
}

--batch_foobarbaz
Content-Type: application/http
Content-ID: <response-item2:12930812@barnyard.example.com>

HTTP/1.1 200 OK
Content-Type: application/json
Content-Length: response_part_2_content_length
ETag: "etag/sheep"

{
  "kind": "farm#animal",
  "etag": "etag/sheep",
  "selfLink": "/farm/v1/animals/sheep",
  "animalName": "sheep",
  "animalAge": 5,
  "peltColor": "green"
}

--batch_foobarbaz
Content-Type: application/http
Content-ID: <response-item3:12930812@barnyard.example.com>

HTTP/1.1 304 Not Modified
ETag: "etag/animals"

--batch_foobarbaz--
```

##### Restricting return data

Restricting return data is quite important for performance issue. If not restricting, you end up having a big request, that is expensive over the network, and expensive to interpret. Therefore, all your infrastructure suffers from non-restricted data.

Besides, there can be some security issues when not restricting data, like password, or internal secret Identifier...

##### Paginating results

Pagination is very important. It is a global error not to paginate data that can grow infinitely. There will be a point in time where your data are too big to be queried. Therefore, pagination on server side is great to keep the data small, increasing network and CPU performance.

##### Caching results

Caching results can greatly improves performance of your application. Instead of targeting the server each time a request is made, a cache (managed by Cloud CDN for instance) is created once and re-used many times. This reduces a lot the latency of the application.

The Cache needs to be properly managed, with duration time and so on...

Can also be great for users with poor internet connection. 

##### Error handling (e.g., exponential backoff)

There are cases when the server responds with an error. What should you do when it is such a case ? A practice is to retry the request, to make sure it was just an isolated error, with no repercussion. But what if the error keeps happening ? Then what should you do ? Try again like an idiot, to make sure the system will never be able to recover ? 

A solution is to use Exponential backoff, which makes your client retries requests, but by waiting longer and longer between each call. This could give time for the server to get back up again, before receiving new calls.

##### Using service accounts to make Cloud API calls

When using gcloud, the tool is connected to the login you provided. You can authenticate using a service account by doing:
```shell script
gcloud auth activate-service-account [ACCOUNT] --key-file=KEY_FILE.json
```
* The KEY_FILE is the key file created for your service account.

To create a service account:
```shell script
gcloud iam service-accounts create NAME
gcloud projects add-iam-policy-binding PROJECT_ID --member="serviceAccount:NAME@PROJECT_ID.iam.gserviceaccount.com" --role="roles/owner"
gcloud iam service-accounts keys create KEY_FILE.json --iam-account=NAME@PROJECT_ID.iam.gserviceaccount.com
```

You can also reconstitute the JWT token for that service account, and send it over your HTTP request in the header `Authorization: Bearer $TOKEN`.  Check this out: https://medium.com/@stephen.darling/oauth2-authentication-with-google-cloud-run-700015a092c2

Globally, to authenticate an HTTP request, the service uses the header `Authorization` to identify the owner of the action.

## Section 5: Managing application performance monitoring

### 5.1 Managing Compute Engine VMs. Considerations include:

#### Debugging a custom VM image using the serial port

If you use Google provided image, the chances are you will not face problems. If you face them anyway, they might be after the startup. If that is the case, you could connect using SSH to have more information and try to debug.

But if you are using a custom image, the VM instance might fail to boot. To diagnose this kind of errors, and try to find a solution, you can use a serial port provided by the image. Usually, a Linux image supports 4 ports `/dev/ttyS0-1-2-3`. The serial port is reserved for admninistation task, like debugging, very technical image manipulation.

By default, the serial port is disabled. You can enable it on project or instance level:
```shell script
gcloud compute project-info add-metadata \
    --metadata serial-port-enable=TRUE

gcloud compute instances add-metadata instance-name \
    --metadata serial-port-enable=TRUE
```

And then to connect, you can do:
```shell script
gcloud compute connect-to-serial-port instance-name
```

Please note the `/dev/ttyS0` port is the port used for all systemd output, which can be very verbose. If you don't want your command to be mixed with systemd logs, you can connect on another port:
```shell script
gcloud compute connect-to-serial-port instance-name --port 2
```

If you want to be able to log in your instance with the serial port, your system needs to allow user/password connection. With GCP provided image, the password is disabled, and you need to enable it first, by connecting to your instance and executing:
```shell script
gcloud compute ssh instance-name
sudo passwd $(whoami)
```

Please note to login using serial port, your project or instance needs to know your SSH public key to authorize the connection. But anyone can connect to the instance if it knows the instance name, the project and the zone. So be careful, and protect your instance using Firewall rules.

#### Diagnosing a failed Compute Engine VM startup

First, you need to know what's going on your instance. So, you can try to log onto the serial port 1 of your booting image, you could receive some information.

For logs access, you can also use Cloud Logging, which gives you auditlogs, activity logs and data logs on your compute engine. Use AuditLogs for compute engine. 

Then, it could also be a mounted disk that fails. Log in to the instance and try to see what could possibly be wrong.

#### Sending logs from a VM to Cloud Logging

To have logs in Cloud logging, you need to :
* activate the metadata on project or instance level
```shell script
gcloud compute project-info add-metadata \
    --metadata serial-port-logging-enable=true

gcloud compute instances add-metadata INSTANCE_NAME \
    --metadata serial-port-logging-enable=true
```
* to install the Cloud Logging agent on the instance
```shell script
curl -sSO https://dl.google.com/cloudagents/add-logging-agent-repo.sh
sudo bash add-logging-agent-repo.sh
sudo yum list --showduplicates google-fluentd
sudo yum install -y google-fluentd
sudo yum install -y google-fluentd-catch-all-config-structured
sudo service google-fluentd restart
```

#### Viewing and analyzing logs

You can access activity logs directly in the Compute engines interface, or you can use Cloud Logging to view logs.

Just filter for any GCE instances, or the one you want to check.

#### Inspecting resource utilization over time

Use Stackdriver with Charts to inspect resources utilization over time, like HTTP request access, CPU utilization...

### 5.2 Managing Google Kubernetes Engine workloads. Considerations include:

#### Configuring logging and monitoring

GKE by default provides Cloud Logging support that sends logs from the different nodes directly to Cloud Logging. You don't need to install the agent.

But, of course, your application needs to respect the container logging policy, which is logging to STDOUT or STDERR.

Then, it always the same thing with Cloud Logging: You can filter for the resources. Here is a useful resource to use for K8S logs:
```
resource.type=("k8s_container" OR "container" OR "k8s_cluster" OR "gke_cluster" OR "gke_nodepool" OR "k8s_node")
```

#### Analyzing container lifecycle events (e.g., CrashLoopBackOff, ImagePullErr)

* CrashLoopBackOff: The container fails to start, or the healthcheck reports an error (other than 2XX response status). The container keeps failing and can never start. Or, the container has started, but has failed later.
* ImagePullErr: The image can not be pulled to start a container. This could be for many reasons:
   * the image name is incorrect
   * The tag is incorrect
   * What registry are you pulling the image from ?
   * Permission denied ? 

#### Viewing and analyzing logs

As always, check for Cloud Logging to have more logs. Filter by resources, textPayload, LogName, Severity... You have plenty of choice.

You can access centralized logs with Cloud Logging and the GKE UI, but you can also ask the logs for a specific container with `kubectl`.
```
kubectl logs PODS_NAME 
```

#### Writing and exporting custom metrics

You can create custom metrics, based on some logs for instance, to display the information in a chart on your Stackdriver dashboard. 

#### Using external metrics and corresponding alerts

The custom metrics can then by used to create alerts and send notifications to the notification channel (email, pubsub, slack...)

#### Configuring workload autoscaling

The Cluster autoscaling automatically resizes your number of nodes in your GKE cluster based on the resource requests. If your workloads requires more resources and the current cluster can't give them, the cluster will scale up to meet the new demands. On the other hand, the cluster scales down when the resource request is low.

Be careful, as Cluster autoscaling can remove a compute engine from your cluster, and so kills all running PODs on it. Design your workload to tolerate this kind of interruption.

But, to have a cluster that autoscales, you also need autoscaling for your Deployment. That is managed by Kubectl. 

So sum up, you have 2 levels of autoscaling:
* GKE and the nodes (compute engine instances)
* Kubectl and the Pods

You have two autoscaling mode with GKE:
* Balance: the default one. Autoscales up and down "slowly"
* Optimize-utilization: More aggressive autoscaling. Scales down as soon as the cluster can be sized down because of resource request. Be careful, this is not ideal for serving workload, and work best for batch workloads.

Your Pods can be autoscaled in two ways:
* Horizontal: We add more Pods to support the workloads
* Vertical: GKE analyses your Real PODS memory consumption, and adjust it to have an optimized resource utilization
    * Please note it does not work well with JVM-based workload as the usage is hidden by the JVM.

### 5.3 Troubleshooting application performance. Considerations include:

#### Creating a monitoring dashboard

With Stakdriver, you can create cross project dashboard with predefined charts based on your GCP services. It is a manageable dashboard where you can create charts and position them on predefined area.

#### Writing custom metrics and creating log-based metrics

Custom metrics are metrics defined by users. They rely on the same element as the built-in Cloud Monitoring metrics use:
* A set of data points
* Metric type information, which tells you what the data point represent
* Monitored-resource information, which tells you where the data points originated.


Log-based metrics are metrics define using Cloud Logging. You can create a metric that is a predefined filter for log entries. With this log based metric, you can then define autoscaling, or alert policy based on these logs aggregation for instance...

#### Using Cloud Debugger

Cloud Debugger works with Source Repositories and a Google Agent installed on the different application. By default, App engine provided the Google Agent to be able to use Cloud Debugger. For a Container based application (GKE, Cloud Run) you need to install the agent in the Dockerfile and use some configuration. For GCE, just install the Agent on the GCE instance.

```shell script
RUN mkdir /opt/cdbg && \
     wget -qO- https://storage.googleapis.com/cloud-debugger/compute-java/debian-wheezy/cdbg_java_agent_gce.tar.gz \
     | tar xvz -C /opt/cdbg

java -agentpath:/opt/cdbg/cdbg_java_agent.so -jar ...
```

Then, you can use Cloud Debugger to :
* Capture snapshot on production of your code. Like a breakpoint, set where you want to capture the information, and you get a snapshot of the parameters of your method, and other information. 
* Dynamically add log line that can be found in the Cloud Logging (if configured). Very handy to understand what happens in production if you are missing some logs.

#### Reviewing stack traces for error analysis

With the agent installed, the error are also catched in Error Reporting, where you can analyse the Stacktrace to try to understand and fix the error in your code. You can add notifications on some errors, making sure you are warned when something happens in your application

#### Exporting logs from Google Cloud

Cloud Logging allows you to export the logs. You can create a Sink to export the logs:
* A Cloud Logging Bucket for log retention (not provided by Cloud Logging)
* BigQuery dataset for batch analysis
* Cloud Storage bucket
* Cloud PubSub for real time analysis of logs

#### Viewing logs in the Google Cloud Console

Using the gcloud tool, you can request the logs of Cloud Logging 
```
gcloud logging tail (needs grpc installed)
gcloud logging logs list (list all logs resources)
gcloud logging read "projects/truaro-test-gcp/logs/run.googleapis.com%2Fstdout"
```

#### Reviewing application performance (e.g., Cloud Trace, Prometheus, OpenTelemetry)

Cloud Trace monitors the latency of your application. But you have to install and configure your application (with opencensus dependencies for Java) to trace the request made to your app. 

When using GKE and Istio (or Anthos), by default, the Mixer traces the request between the container. Istio also comes with Promotheus and Telemetry to display the logs and trace on a UI to help you monitor your application.

Istio installs a sidecar container on each PODS to manage the network of your containers. This sidecar proxy also sends request to Mixer to enable a nice dashboard to help you monitor your application.

#### Monitoring and profiling a running application

Install the Cloud Agent (except on AppEngine standard) to store trace and profiling information about your information.

#### Using documentation, forums, and Google Cloud support