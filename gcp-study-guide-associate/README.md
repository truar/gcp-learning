# 1. Setting up a cloud solution environment

## 1.1 Setting up cloud projects and accounts. Activities include:
### Creating projects

A project contains all your cloud resources needed to build yur application.
In the Google cloud console > in the navbar > the dropdown list where you can click on "Create project"<br/>
Make sure you select the Organization, and then choose the billing account.

For my application CloudCMR, it is the global project that contains my app engine, identity configuration, storage, database... All in one project.
Deleting this project deletes all the associated resources.

### Assigning users to predefined IAM roles within a project

IAM allows to manage access rights to your Google Project, on specific services (compute/app engine, storage) with certain roles

To add a member : `IAM > ADD >` Set email and first roles

Once added, to edit : `IAM >` Click on the pen next the user to update > Add / remove roles

To have another user setting roles and creating user : `IAM > Security admin`

For CloudCMR, this is the place to add users that could help administrating the project, or dealing with the version upgrade, see or configure the monitoring...
 
### Managing users in Cloud Identity (manually and automated)

To manually manage Cloud Identity : API & Services > Credentials > to create credentials

For your project, you can configure a oauth consent screen. This screen will be displayed when the user will need to authenticate to the app.

Automatically ? I don't know

Questions about authentication for CloudCMR : 
* How can I register my user with google identity
* Can I use Google Identity as my SSO
* What URL should I call when authenticating with OAuth2
* How to manage multiple email address if all users are not from the same company

What I want, is a SSO for my CloudCMR users. The home page redirects to the login oauth2 google page if they are not logged in.

Check this link: https://spring.io/guides/tutorials/spring-boot-oauth2/

### Enabling APIs within projects

API & Services > Library. Then browses or filter for API you want to use. The API are used to enable such things as Compute engine for instance. 

When accessing Compute engine when the API is not enabled yet, it automatically enables the API

### Provisioning one or more Stackdriver workspaces

StackDriver : a stack to do live monitoring on your application.
When you enter the `Stackdriver > Monitoring` for the first time, it creates a workspace associated to your project. Takes some minutes.

You have many things in StackDriver :
* Monitoring: Create a workplace where you can create and configure your dashboard. You can create alert on network connection, Uptime check of your service, browses through the dashboard
* Debug: 
* Trace:
* Logging:
* Error reporter:
* Profiler: 

For CloudCMR, I could check if the app is still running, check the connection to see if I am not facing a denial of service, check the CPU, JVM usage  ?

## 1.2 Managing billing configuration. Activities include:
### Creating one or more billing accounts

A billing account is an account that will pay the bill every month.

For instance, at Zenika, we have one billing account: Facturation Zenika. This account can see the monthly cost of our entire GCP projects.

If it was for CloudCMR, I would create one billing account for them, and linked the gcp project to this billing account. This way, they will directly pay their bill.

### Linking projects to a billing account

Go to Billing. If you have multiple billing accounts, then open `Account management`. Here, there is the list of known projects.
You can then change the project Billing account by clicking the "Three dots" next to your project.

When you create a new project and have many billings account, then you can choose which one you want to link your project with.

For CloudCMR, I'd linked the cloud-cmr-project to the CMR billing account.

### Establishing billing budgets and alerts

Go to `Budgets & Alerts` and create a budget. Choose the limit, and then configure the threshold to receive emails. 
You can configure this to a Pub/Sub topic to do extra actions.

For me, I configured an alert is a start paying (1€).

For CMR, it could be no more than 100€ a month.

### Setting up billing exports to estimate daily/monthly charges

To have a billing exports, you need to configure a BigQuery... You can also choose a more classic "File export". It exports the file in a bucket Google Storage.
Either way, you need to configure a Google Instance.

There is a difference though between BigQuery and File export:
> File export to CSV and JSON captures a smaller dataset than export to BigQuery. For example, the exported billing data does not include resource labels or any invoice-level charges such as taxes accrued or adjustment memos.

## 1.3 Installing and configuring the command line interface (CLI), specifically the Cloud SDK (e.g., setting the default project).

https://cloud.google.com/sdk/docs/quickstart-macos

```
gcloud init
Enter your credentials (open your browser)
Select/Enter your projectId : gcp-associate-cert-prep-truaro
Configure the default Zone : 17 (europe-west1-b)
```

Change the login (open the browser)
```
gcloud auth login
```

Changing your default project
```
gcloud config set core/project gcp-associate-cert-prep-truaro
```

Changing the default region & zone
```
gcloud config set compute/region europe-west1
gcloud config set compute/zone europe-west1-b
```

# 2. Planning and configuring a cloud solution

## 2.1 Planning and estimating GCP product use using the Pricing Calculator

https://cloud.google.com/products/calculator#id=

The services are not so expensive. You need to know some data (volume for instance), but other than that, pretty easy to know
what is going on.

If I have 5 app engines communicating and storing file, 24/7, it costs 130€ (99% of costs comes from app engine : 127€)

It is about the same price for kubernets cluster of 5 nodes, and 5 compute engines.

With 5 postgreSQL instances, for 10Gb and 5Gb, it is 44€ a month.

## 2.2 Planning and configuring compute resources. Considerations include:
### Selecting appropriate compute choices for a given workload (e.g., Compute Engine, Google Kubernetes Engine, App Engine, Cloud Run, Cloud Functions)

#### Compute engine 
Compute engine (IaaS) creates a Virtual Machine with the OS you chose. You have root access to the machine. You can install any software or application you need.
This is perfect when you need full control over your VM (installing your own OS, packaging with your "bottom" layer to fit your companies requirements...)
You an also choose the type of machine you need, to specifically match your needs in terms of performance/costs. 
Also possible to do live migration with no down time (google feature).
Have a preemptible VM to minimize your costs when running fault-tolerance non very important job. The resources allocated to your job can be reallocated
given the load of the resources and the needs of Google. (If a cluster is down for some reason, and the resources need to be reallocated, then your preemptible VM will a possible candidate to get more resources)
You can also ask for a sole tenant Nodes, which gives you a dedicated hardware to work on (mostly security constraints by your company)

#### Google kubernetes engine
Build a kubernetes cluster of Compute engine. Auto-repair, Auto-scale, versioning... 
More expensive than compute engine, as you pay for as many compute engine you have in your cluster. And more often, 
if you have a kube cluster, you need more than 1 compute engine.

#### App engine 
App Engine is a serverless approach that allow the developer to focus only on the application. The app engine, given configuration, can be easily scaled
By default, you can run Java, PHP, Node.js, Python, C#, .Net, Ruby, and Go, or even have your runtime exec environment.
You only to pay for the resources we consume...
You can also do A/B testing, routing given the version, use stackdriver, all of this without too much configuration.

What resources ? If I have an application server running, I'am consuming CPU all the times... So I pay full price, right ?

To deploy your application, appEngines creates bucket to upload file on it. What does it need to upload ?

Great when you are a devTeam and not want to deal with runtime issue

#### Cloud run
Seems to be an in-between approach between app engine and compute engine. You can deploy any application you need, you are not limited to the 
runtime environment provided by your serverless env. Just configure a docker file, and you're good to go. 

#### Cloud functions
The lightest serverless configuration. Just upload the code you want to execute. Triggered by event (http request, pub/sub, storage management...)
Nothing to worry about, the code will be executed, that's all we need to know
Great also for testing new functionality, or exploring functional needs.

### Using preemptible VMs and custom machine types as appropriate

Have a preemptible VM to minimize your costs when running fault-tolerance non very important job. The resources allocated to your job can be reallocated
given the load of the resources and the needs of Google. (If a cluster is down for some reason, and the resources need to be reallocated, then your preemptible VM will a possible candidate to get more resources)

## 2.3 Planning and configuring data storage options. Considerations include:
### Product choice (e.g., Cloud SQL, BigQuery, Cloud Spanner, Cloud Bigtable)

#### Cloud SQL
DbaaS (DatabaseAsAService). You can connect to a SQL RDBM like MySQL or PostgreSQL or SqlServer and connect your app to it.
Backups enables, provisioning capacity... Just easy to get a SQL Database without having to configure it.

#### BigQuery
It is a serverless cloud date warehouse. Allow you to code a query that will analyse Petabytes of Data easily.
 * BigQuery ML : Can use SQL to do the request.
 * BigQuery BI : Support BI treatment integrates with other tool like : Google Data Studio, Looker, Sheets...
 * BigQuery GIS : Allow to do query in a geospatial dataset
 
To try a bit, you can have access to many public dataset, but I haven't figured out exactly how it works. I couldn't make a request
on this dataset, I think I need another steps (like creating table... ?)

#### BigTable 
BigTable is a NoSQL Database, with a low latency and is replicated automatically. Supports dev standard of the HBase API. 
Wors also with hadoop, or cloud dataflow.
When you apps generates more Data, you have nothing to configure. BigTable will automatically scale.
But you need Terabytes before being worried...

#### Cloud spanner
Seems to be a custom specific database system built by google, that allows, like always, to access your data with low latency.
Support both transactional and non transaction database. 
It is way more expensive than a classic RDBMS or NoSQL Database.
Replicated database, offering something clearly new given the price

#### Google cloud Storage : bucket
A bucket is a place reserved for you where you can store your objects in it. There is no real notion of folder... it seems to be 
here only for convenience. There is no file modification, only a place to store files (then edit = delete + add new version)
You can access via an API to upload files without using the console. Your apps can be connected to it in order to 
upload or download files.
Everything is backed-up, making sure you do not loose any data. 

#### Cloud filestore
Is real filesystem that allows you to managed your files like any others filesystems you work with on your computer.
It is fast, consistent, simple and scalable (okay, we get it, everythings google does it almost those four qualities)

#### Firestore
A databse that keep async your client and server data at realtime. Provide a SDK for any mobile (Androis, IOS) and websites.
It is a NoSQL document database. Provide an offline support in case of a network failure between the server and the firestore database.
Scalable.

#### Datastore
Is the old generation of firestore. No need to go further. same principles.

#### Cloud memorystore
Provide a redis cache in memory database to increase caching system and the global performance of your application.

### Choosing storage options (e.g., Standard, Nearline, Coldline, Archive)

Used with Google cloud Storage to fit the specific needs of your object access and duration.

* Standard: Best fit for "Hot data", that is access frequently and stored only for a brief period of time. Have the best SLA.
* Nealine: Is more low-cost than standard. Have 30 days of minimum storage duration (you can't delete a file before ?) and is great when accessing data on a monthly basis, like once a month. SLA eq to the 2 belows. 
* Coldline: very low cost, keep files longer (90 days minimum), file access once a quarter.
* Archive: very very low cost, Perfect for disaster recovery. Access data once a year. Bigger cost when accessing data (comparing to standard). Store files for 365 days.

Except for standard, the data is not means to be retrieved on a daily basis. The storage is cheaper, but the access is more expensive.
It is a trade-offs.

## 2.4 Planning and configuring network resources. Tasks include:
### Differentiating load balancing options

#### LoadBalancer
A load balancer distributes traffic across multiple instances of your application. Avoid your application to handle too much requests,
to be overloaded, and keep it fast (at least does not get slower).

Load balancer can be internal (inside your own VPC, or google cloud) and external (when clients comes from internet).

* For CloudCMR, it would be external. Or, to "protect" the admin website, we could use a VPN, and have something internal ? Or would it be still external ?
* For a classic WebSite, it is external.
* For communication across instances, inside the google cloud network, it could be internal.

Load balancer can also be global (across many regions) or regional (inside a single region). Not every account can create a global load balancer. You need to be premium.

Choosing a Region/Zone depends on the location of your customer, some regulations a certain region can have. For my case study, I have only a single region (europe-west1 i.e belgium)

A Load balancer can be on the Layer 4 (TCP/UDP/IP)
or on the Layer 7 (HTTP, headers forwarding), and redirect given attributes from the request

Available LoadBalancer:

* Internal HTTP/S LoadBalancer: when doing HTTP request, it the best choice. Onlh regional. Only IPv4, only inside same VPC as the client. Don't preserver client IP
* External HHTP/S LoadBalancer: same as internal, but can manage IPv6. Open connection to the world. Can be general (if premium) or regional (if standard).  Don't preserver client IP
* SSL Proxy: Great for other connection over SSL (IMAP, WebSocket). Can be general (if premium) or regional (if standard).  Don't preserver client IP
* TCP Proxy: Same as SSL, but for unsecured connection.  Don't preserver client IP
* External TCP/UDP. Not a proxy, but a pass-through. The server answers directly to the client. Perserve IP client. Only regional.
* Internal TCP/UDP : same, as above, but only internal.

### Identifying resource locations in a network for availability
The resources are spread:
* Physically: Which means, you need to know the region and the zone it is into in order to determine a potential failure.
* Logically: In which VPC is my resources. Are they behind a load balancer ? If yes, which one ? Internal or external ?

If one of my region fails, who is taking over ? I might need to have backup somewhere in another region.

The physical location (region) is also a factor when dealing with performance : where my users are ? Is it faster to have something near them ?

You can configure health check to help your loadbalancer and not sending a request in a non working resources.

### Configuring Cloud DNS
Manage DNS access to the resources hosted on the google cloud. 
Can also do DNS forwarding to forward requests on others onpremises cluster.
Work also if you bought a DNS name, otherwise, you can use one available.

# 3. Deploying and implementing a cloud solution
## 3.1 Deploying and implementing Compute Engine resources. Tasks include:
### Launching a compute instance using Cloud Console and Cloud SDK (gcloud) (e.g., assign disks, availability policy, SSH keys)
Simple command: 
```
gcloud compute instances create my-instance-name \
    --machine-type f1-micro \
    --zone europe-west1-b
```

More complex command:
```
gcloud compute instances create my-instance-name2 \
    --zone=europe-west1-b \
    --machine-type=f1-micro \
    --subnet=default \
    --network-tier=PREMIUM \
    --metadata=block-project-ssh-keys=true \
    --maintenance-policy=MIGRATE \
    --service-account=49043265818-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --image=debian-9-stretch-v20200210 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=my-instance-name \
    --create-disk=mode=rw,auto-delete=yes,size=500,type=projects/gcp-associate-cert-prep-truaro/zones/us-central1-a/diskTypes/pd-standard,name=disk-2,device-name=disk-2 \
    --reservation-affinity=any

```
When you create a VM, it has a default boot disk of 10Gb. You can add another bigger disk to your server if you need.

Availability policy enables to choose :
* preemptive VM or not (it the VM can be shut down, and the resources reallocated)
* If a maintenance on the server requires a VM migration, if you want to avoid downtime
* In case of VM failure, can automatically restart the instance

### Creating an autoscaled managed instance group using an instance template
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
gcloud compute instance-templates create my-instance-template \
     --machine-type=f1-micro \
     --metadata-from-file startup-script=startup.sh
```

More complex command:
```
gcloud compute instance-templates create my-instance-template-2 \
    --machine-type=f1-micro \
    --network=projects/gcp-associate-cert-prep-truaro/global/networks/default \
    --network-tier=PREMIUM \
    --metadata=startup-script=\`\`\`$'\n'\#\!\ /bin/bash$'\n'apt-get\ update$'\n'apt-get\ install\ -y\ nginx$'\n'service\ nginx\ start$'\n'sed\ -i\ \
    --\ \'s/nginx/Google\ Cloud\ Platform\ -\ \'\"\\\$HOSTNAME\"\'/\'\ /var/www/html/index.nginx-debian.html$'\n'EOF$'\n'\`\`\` \
    --maintenance-policy=MIGRATE \
    --service-account=49043265818-compute@developer.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/devstorage.read_only,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append \
    --tags=http-server \
    --image=debian-9-stretch-v20200210 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=my-instance-template-2 \
    --reservation-affinity=any

```
 3. Create a `Target Pool` to have a single entry point into the future `Instance group`
```
gcloud compute target-pools create my-target-pool
```

 4. Create the `Instance group` connected to the `Target pool` previously created. 2 compute engines must be created.
 The goal of the `Instance group` is to keep together the compute engines.
```
gcloud compute instance-groups managed create my-instance-group \
         --base-instance-name my-instance \
         --size 2 \
         --template my-instance-template \
         --target-pool my-target-pool
```
More complex command to enable autoscaling:
```
gcloud compute instance-groups managed create instance-group-1 \
    --base-instance-name=instance-group-1 \
    --template=my-instance-template \
    --size=1 \
    --zone=europe-west1-b

gcloud compute instance-groups managed set-autoscaling "instance-group-1" \
    --zone "europe-west1-b" \
    --cool-down-period "60" \
    --max-num-replicas "3" \
    --min-num-replicas "1" \
    --target-cpu-utilization "0.6" \
    --mode "on"
```
Autoscaling can be enabled on 3 metrics :
* CPU load
* HTTP Load balancing utilization
* A custom metric defined in the stackdriver 

 5. Create a firewall rule to allow HTTP 80 traffic.
```
gcloud compute firewall-rules create www-firewall --allow tcp:80
```
### Generating/uploading a custom SSH key for instances
```
ssh-keygen -t rsa ~/.ssh/my_key
```
A user has a private key and public key. You can allow the access to your VM by SSH in many ways :
* Add a public key to your project metadata ssh-keys (copy paste the content of `~/.ssh/my_key.pub`) and allow project-wide ssh keys
* Add a public key yo your compute engine instance

### Assessing compute quotas and requesting increases
Quotas limits usage of certain elements in GCP. You have a quota per project and also per region, in order to give enough elements to all the users.
Check quotas via the console (IAM & Security > Quotas) or use command:
```
gcloud compute project-info describe
gcloud compute regions describe europe-west1
```

### Configuring a VM for Stackdriver monitoring and logging
### Installing the Stackdriver Agent for monitoring and logging
For the monitoring agent:
```
curl -sSO https://dl.google.com/cloudagents/install-monitoring-agent.sh
sudo bash install-monitoring-agent.sh
```

For the logging agent:
```
curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh
sudo bash install-logging-agent.sh --structured
```
Note: The --structured flag lets the Logging agent send structured data to Cloud Logging. For more information, see Structured logging operations.

Then, you can configure using stackdriver, and create an uptime check with an alerting email.

## 3.2 Deploying and implementing Google Kubernetes Engine resources. Tasks include:

### Deploying a Google Kubernetes Engine cluster
A cluster is a groups of nodes. A cluster will manage its pods inside the nodes.
Kube deploys the podes inside its nodes.
Pods are the smallest deployable units of computing that can be created and managed in Kubernetes.

Default is a n1-standard-1 compute instance, with 3 nodes.
```
gcloud container clusters create my-kube-cluster
```
Weirdly, it doesn't seem to be working with the below commands.
```
gcloud container clusters create my-kube-cluster \
    --zone "europe-west1-b" \
    --machine-type "f1-micro" \
    --num-nodes "3" \
    --enable-autoscaling \
    --min-nodes "0" \
    --max-nodes "4" \
    --enable-autoupgrade
```

More complex command:
```
gcloud container clusters create my-kube-cluster \
    --zone "europe-west1-b" \
    --no-enable-basic-auth \
    --cluster-version "1.14.10-gke.17" \
    --machine-type "f1-micro" \
    --image-type "COS" \
    --disk-type "pd-standard" \
    --disk-size "10" \
    --metadata disable-legacy-endpoints=true \
    --scopes "https://www.googleapis.com/auth/devstorage.read_only","https://www.googleapis.com/auth/logging.write","https://www.googleapis.com/auth/monitoring","https://www.googleapis.com/auth/servicecontrol","https://www.googleapis.com/auth/service.management.readonly","https://www.googleapis.com/auth/trace.append" \
    --num-nodes "4" \
    --enable-stackdriver-kubernetes \
    --enable-ip-alias \
    --network "projects/gcp-associate-cert-prep-truaro/global/networks/default" \
    --subnetwork "projects/gcp-associate-cert-prep-truaro/regions/europe-west1/subnetworks/default" \
    --default-max-pods-per-node "110" \
    --enable-autoscaling \
    --min-nodes "0" \
    --max-nodes "4" \
    --addons HorizontalPodAutoscaling,HttpLoadBalancing \
    --enable-autoupgrade \
    --enable-autorepair
```

One you have created the cluster, you can start deploying pods.
With pods, you can do rolling update, and more.

### Deploying a container application to Google Kubernetes Engine using pods
 2. Authenticate to enable the `kubectl` command connected to your clusters named `nucleus-cluster
```
gcloud container clusters get-credentials my-kube-cluster
```
 3. Create the `Workload` (application) and deploy it on the nodes
```
kubectl create deployment hello-app --image=gcr.io/google-samples/hello-app:2.0
```
 4. Create a `LoadBalancing` rule (Network > LoadBalancing) item to expose the API on port 8080
```
kubectl expose deployment hello-app --type=LoadBalancer --port 8080
```
 5. After couple of seconds, get the IP check your service : http://104.196.132.86:8080
```
kubectl get service
```
You can choose any images in a registry.

### Configuring Google Kubernetes Engine application monitoring and logging
You can enable the kubernetes stackdriver. With version 14 and 15, it is enabled by default. 
For logging, you can select the instance you want to watch. If you write logs to console, then you should see them in 
the logging view.

## 3.3 Deploying and implementing App Engine, Cloud Run, and Cloud Functions resources. Tasks include, where applicable:

### Deploying an application, updating scaling configuration, versions, and traffic splitting
#### App engine
App engine is made to make life easy for developers to get something scalable.
The tree of app engine is the following :
* 1 application, composed of several services (micro-services, functional feature)
* 1 service is versioned, and you can have multiple versions of the same service. A service is identified by a name.
* 1 specific version of the service is deployed onto instances

To deploy an app, you just need to have a project with an `src/main/appengine/app.yml` file. Then, in your spring boot project, it works like usually.

To deploy your app, run: 
```
mvn clean package appengine:deploy -Dapp.deploy.projectId=gcp-associate-cert-prep-truaro
```

Once the application is deployed, you have in your google console : 
* 1 service named `default`. To have a service named differently, you need to change the `appengine/app.yml`
* If I have multiple services, how can I make the user accessing those services ?
> A service is identifier by a name, and the name is found in the appengine/app.yml `service: quarkus-hello`
> Then, you can access https://quarkus-hello-dot-gcp-associate-cert-prep-truaro.appspot.com
* Your app engine can communicate together using HTTP requests.
* How to deploy multiple versions of the same service in command line ?
> Didn't find yet. Currently, the `-Dapp.deploy.version=...` is not read by `appengine:deploy` 
* How can you manage the traffic splitting ?
> Traffic splitting is easily achieved though the google console.
* How to stop auto-scaling ? Not even sure it is possible, as it is the purpose of app engine. But we might be able to tune it a bit.
> I didn't find any options that showed it was possible to change that.

#### Cloud Run
Cloud Run lets you run classic Docker container. You must have your application being able to listen the port `$PORT` provided.

Your image needs to be in a registry. Then, it is easy to use the google console to start a new instance.
There is a lot of parameters to override if needed.
* Choose the image
* Choose the region (region, not zone)
* Choose the management type : Fully managed (nothing to do, let google handle the scaling) | Anthos : a GKE cluster to manage the cloud run containers.
* Override the default command, the default port, the cpu allocated per one cloud run container, and the memory
* How many requests at the same time before scaling up
* Number of instances running in the same time
* Connection to a SQL Server

* How to deploy a CloudRun service ?
```
gcloud run deploy helloworld --image=gcr.io/cloudrun/hello --set-env-vars="JAVA_TOOL_OPTIONS=-XX:MaxRAM=256m" --region=europe-west1 --allow-unauthenticated --platform=managed
```
* How to delete a CloudRun service ?
```
gcloud run services delete helloworld-custom --platform=managed --region=europe-west1
```
* How to update scaling configuration ?
> When managed, nothing to do. You can change the value of the maximum number, but that's it. You can split traffic by versions.
> When GKE, needs to deal with the GKE instances
* How to play with traffic splitting ?
> When deploying a new version, you can choose whether to migrate traffic directly, or progressively.
> You can delete a version only if there is no more traffic on it.
> I didn't find any options to manage traffic given a cookie or something. Seems to be hard to do A/B testing in this case.
```
gcloud run services update-traffic helloworld --to-revisions helloworld-00005-wik=50 --platform=managed --region=europe-west1
```
* How to see logs and monitoring ?
> Unlike app engine, there is not Stackdriver on CloudRun. The logging and monitoring is directly inside the CloudRun page.
* How to allow unauthenticated user ?
> Add the role `Cloud Run Invoker` to your CloudRun service for All users.

#### Cloud Functions
Cloud Functions are great to have very lightweight components to execute a very specific code. You can trigger this function given different events:
* HTTP requests (classic endpoint exposition)
* Cloud Pub/Sub messages received in a topic
* Cloud Storage when a file is stored in a filesystem
* (Beta) : Firestore, analytics FireBase, Firebase authentication, Firebase realtime db, firebase remote config

What is great for CloudFunctions in JS is that it is really fast to get an answer even if the app was "sleeping".

Here is a example of a lab made on qwirks, of a Function publishing to a Pub/Sub topic when a file is uploaded on a Storage (bucket).
> Create a folder that will contain your files
```
mkdir my-cloud-function
cd my-cloud-function
```

> Create the file index.json
```
/* globals exports, require */
//jshint strict: false
//jshint esversion: 6
"use strict";
const crc32 = require("fast-crc32c");
const gcs = require("@google-cloud/storage")();
const PubSub = require("@google-cloud/pubsub");
const imagemagick = require("imagemagick-stream");

exports.thumbnail = (event, context) => {
  const fileName = event.name;
  const bucketName = event.bucket;
  const size = "64x64"
  const bucket = gcs.bucket(bucketName);
  const topicName = "kraken-topic";
  const pubsub = new PubSub();
  if ( fileName.search("64x64_thumbnail") == -1 ){
    // doesn't have a thumbnail, get the filename extension
    var filename_split = fileName.split('.');
    var filename_ext = filename_split[filename_split.length - 1];
    var filename_without_ext = fileName.substring(0, fileName.length - filename_ext.length );
    if (filename_ext.toLowerCase() == 'png' || filename_ext.toLowerCase() == 'jpg'){
      // only support png and jpg at this point
      console.log(`Processing Original: gs://${bucketName}/${fileName}`);
      const gcsObject = bucket.file(fileName);
      let newFilename = filename_without_ext + size + '_thumbnail.' + filename_ext;
      let gcsNewObject = bucket.file(newFilename);
      let srcStream = gcsObject.createReadStream();
      let dstStream = gcsNewObject.createWriteStream();
      let resize = imagemagick().resize(size).quality(90);
      srcStream.pipe(resize).pipe(dstStream);
      return new Promise((resolve, reject) => {
        dstStream
          .on("error", (err) => {
            console.log(`Error: ${err}`);
            reject(err);
          })
          .on("finish", () => {
            console.log(`Success: ${fileName} → ${newFilename}`);
              // set the content-type
              gcsNewObject.setMetadata(
              {
                contentType: 'image/'+ filename_ext.toLowerCase()
              }, function(err, apiResponse) {});
              pubsub
                .topic(topicName)
                .publisher()
                .publish(Buffer.from(newFilename))
                .then(messageId => {
                  console.log(`Message ${messageId} published.`);
                })
                .catch(err => {
                  console.error('ERROR:', err);
                });

          });
      });
    }
    else {
      console.log(`gs://${bucketName}/${fileName} is not an image I can handle`);
    }
  }
  else {
    console.log(`gs://${bucketName}/${fileName} already has a thumbnail`);
  }
};
```
> Create the file package.json
```
{
  "name": "thumbnails",
  "version": "1.0.0",
  "description": "Create Thumbnail of uploaded image",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "@google-cloud/storage": "1.5.1",
    "@google-cloud/pubsub": "^0.18.0",
    "fast-crc32c": "1.0.4",
    "imagemagick-stream": "4.1.1"
  },
  "devDependencies": {},
  "engines": {
    "node": ">=4.3.2"
  }
}
```

Create a Cloud Functions to execute the above code. It is triggered when a file is uploaded into the bucket.
You don't need to specify the location of the index.js and package.json file. But you need to be in their folder when
you execute the `gcloud functions deploy` command.
```
gcloud functions deploy kraken-function \
    --runtime nodejs8 \
    --trigger-resource kraken-bucket01 \
    --trigger-event google.storage.object.finalize \
    --entry-point=thumbnail \
    --allow-unauthenticated
```

Upload a JPG file into the bucket to trigger the `kraken-function`
```
cd ..
wget --output-document map.jpg https://storage.googleapis.com/cloud-training/gsp315/map.jpg
gsutil cp map.jpg gs://kraken-bucket01/
```

* How to do traffic splitting ?
> Doesn't seem to be possible. Traffic splitting is when you have multiple versions and want to do some light rolling update.
> For cloudFunctions, the traffic passed from 100% to 100% when the version is deployed.
* Can i do versioning ?
> It is done automatically when you update the Functions inside the console. The previous is still active while the new one is being deployed.
> When the next version is active, the previous one is deleted.
* How is auto-scaling managed ?
> You don't have access to that. It is automatically managed by Google.

To conclude, between the 3 of these products :

| Product        | Versioning | Traffic splitting                 | Scalability management    | Execution environment  |
|----------------|------------|-----------------------------------|---------------------------|------------------------|
| App engine     | YES        | YES (with cookie, region, random) | Max instances             | Many classic languages |
| CloudRuns      | YES        | YES (random)                      | Min/Max instances, or GKE | ANY                    |
| CloudFunctions | NO         | NO                                | No customization          | Limited to Functions   |


### Deploying an application that receives Google Cloud events (e.g., Cloud Pub/Sub events, Cloud Storage object change notification events)

## 3.4 Deploying and implementing data solutions. Tasks include:

### Initializing data systems with products (e.g., Cloud SQL, Cloud Datastore, BigQuery, Cloud Spanner, Cloud Pub/Sub, Cloud Bigtable, Cloud Dataproc, Cloud Dataflow, Cloud Storage)
#### Cloud BigTable
It seems pretty expensive at first... For a production database, it costs 1500$/month (cluster cost: 3 nodes, storage cost: 1TB SSD). 3 times less expensive for development.

* For low cost and development, choose Development as `Instance type`
* SSD or HDD (lower the storage cost, not the cluster cost)

CloudTable is optimized for MapReduce operations, stream processing and machine learning. Is ideal for value no larger than 10MB.

A `Table` (`key/value` map) is made of:
* `row`: representing a single entity, composed of `Columns`
* `column`: individual information about a `row`. A column is identified by a unique `column qualifier` inside a `column family`.
* `rowkey`: identifier to get the row

Cloud Bigtable is not a relational database. It does not support SQL queries, joins, or multi-row transactions. 
Cloud Bigtable is not a good solution for storing less than 1 TB of data.

Technically, it seems close to HBase. There is tables, containing Rows, identified by an ID. There is also the concept of Family, to regroup your data in a logical way.

To create a table
```
cbt createtable my-table
```
To list the table
```
cbt ls
```
To add a `family` to your table
```
cbt createfamily my-table cf1
```
To list the tables families
```
cbt ls my-table
```
To add a new column `c1` in the family `cf1` row `r1`
```
cbt set my-table r1 cf1:c1=test-value
```
To read a table
```
cbt read my-table
```
To delete a table
```
cbt deletetable my-table
```
To delete an instance
```
cbt deleteinstance quickstart-instance
```

#### Cloud Firestore

CloudFirestore is the next solution of CloudDatastore.

##### For Datastore mode
Concepts:
* `Entities`: An element stored with properties
* `property`: Entities individual information. They have a type. Inside the same entity, the same property can have different types (String / Boolean...)
* `namespace`: partition entities into subset. Not every firestore have many namespaces, not mandatory.
* `parent`: Can have inheritance in document.
* `indexes`: To query the data.

##### Native mode
Concepts:
* `Collections`: An set of Documents stored with fields. 
* `fields`: A document. Collections individual information. They have a type. Inside the same entity, the same property can have different types (String / Boolean...)
* `DocumentId`: To identify the document
* `Document` : the information to store
* `nested collections`: A Document can have a sub-collection.
* `indexes`: create composite or single field indexes. automatically indexes every field we have. We can exempt a collection from being indexed.

The console of CloudFirestore allows to create new entities, specified as `kind`. The kind is the group of entities you want to store:
* I want to store `Tasks`, then `Task` is the `kind`
* I want to store `Meals` then `Meal` is the `kind`

Datastore is a NoSQL Document Database. Can support:
* Atomic Transactions: all succeed, or none occur
* High availability
* Scalability
* Flexible storage : Map naturally to object oriented and scripting language
* Balance of Strong and Eventual consistency

Can be good for:
* Product catalogs that provide real-time inventory and product details for a retailer.
* User profiles that deliver a customized experience based on the user’s past activities and preferences.
* Transactions based on ACID properties, for example, transferring funds from one bank account to another.

Not a solution for a relational database, and not a solution for data analytics.

Firestore for Datastore mode uses Firestore with a backward compatibility for Datastore.

Firestore native is the new generation.

Firestore (and Datastore) is a really cheap products, as it is based on the number of operations (read, write, deletes) you do a month, and the storage you need.

#### Cloud filestore
Is a real FileSystem to manage and files/folders. This is then useful to combine that with a compute instance in order to save files on it.

One of the advantages I see is how it is to mount such a filesystem. If you ask for more HDD when creating the compute engine, you need to do more actions (formatting, for instance).

To create a new filestore system:
```
gcloud filestore instances create nfs-server --tier=STANDARD --file-share=name="vol1",capacity=1TB --network=name="default"
```
To get the information about the filestore:
```
gcloud filestore instances describe nfs-server --zone=us-central1-c
```
Connect on SSH onto one of your compute engine and execute the following:
```
sudo apt-get -y update && sudo apt-get -y install nfs-common
sudo mkdir /mnt/test
sudo mount 10.0.0.2:/vol1 /mnt/test
sudo chmod go+rw /mnt/test
```
And your instance can then use your filestore system, as a new disk.

To delete :
```
gcloud filestore instances delete nfs-server 
```

#### Cloud storage
You can store `data` in a `bucket`. A bucket is a place where you will upload all your files in it. There is not a real `folder/file` object,
but you can organize your `object` with a "hierarchical approach". You can't nest bucket inside bucket.

Object name must be unique inside a bucket. A bucket name must be unique across all gcp instances. Easy place to upload files.

Be careful, when designing an application using bucket, favor heavy operations on your object, and not on the bucket, as the bucket
operations cost more money.

You can choose a `storage class`, which classify your data:
* Standard: Best fit for "Hot data", that is access frequently and stored only for a brief period of time. Have the best SLA.
* Nealine: Is more low-cost than standard. Have 30 days of minimum storage duration (you can't delete a file before ?) and is great when accessing data on a monthly basis, like once a month. SLA eq to the 2 belows. 
* Coldline: very low cost, keep files longer (90 days minimum), file access once a quarter.
* Archive: very very low cost, Perfect for disaster recovery. Access data once a year. Bigger cost when accessing data (comparing to standard). Store files for a minimum of 365 days.

To create a bucket (make sure your project is properly set)
```
gsutil mb -b on -l europe-west1 gs://truar-bucket-test/
```
To upload a file (make sure you have it in your filesystem) in your bucket
```
gsutil cp kitten.png gs://truar-bucket-test
```
To download a file in your bucket
```
gsutil cp gs://truar-bucket-test/kitten.png kitten2.png
```
To copy data from bucket to bucket
```
gsutil cp gs://truar-bucket-test/kitten.png gs://truar-bucket-test/folder/kitten3.png
```
To list a bucket data (can also use `ls -l` to get more information)
```
gsutil ls gs://truar-bucket-test
```
> gs://truar-bucket-test/kitten.png<br/>
> gs://truar-bucket-test/folder/

To make your bucket accessible to everyone
```
gsutil iam ch allUsers:objectViewer gs://truar-bucket-test
```
To remove the allUsers access
```
gsutil iam ch -d allUsers:objectViewer gs://truar-bucket-test
```
Role : lecture des objets <=> objectViewer
To give/remove a read access to a single user
```
gsutil iam ch user:thibault.ruaro@gmail.com:objectViewer gs://truar-bucket-test
gsutil iam ch -d user:thibault.ruaro@gmail.com:objectViewer gs://truar-bucket-test
```
To remove an object
```
gsutil rm gs://truar-bucket-test/kitten.png
```
To remove a bucket
```
gsutil rm -r gs://truar-bucket-test
```

#### Cloud SQL
Is a simple RBDMS service, the classic DBAS (Database as a service). You can have a PostgreSQL, MySQL or SQL Server.
Handy when you want to migrate to a dbaas easily without changing your application in a first time.

More expensive than a Firestore storage for instance. But it is not the same purpose either.

Nothing to do really, just create a database using the console, and then use any tool to connect to your database (JDBC for instance).

#### Cloud spanner
Cloud Spanner is a new database system built by google allowing user to make SQL query, store data like usually in a RDBS, 
while achiving high availabilty and replication. 

Before committing a data, the quorum  has to agree about this decision, using the Paxos algorithm. 
To achieve replications, it uses a combinaison of :
* `Read-write` replicas: Store full data, can vote for leaders, can vote for committing, serve reads. Basically, allow you to write and read data.
* `Read-only` replicas: (multi region only) Horizontal scalabilty to read data, replicated from the read-write replicas.
* `Witness` replicas: (multi region only) Can participate to a commit request, can participate to vote for a leader, but can't become a leader, as it doesn't store the full data like a `read-write`

Very similar to a relational schema, you can choose to use a foreign key or nested tables, to group table physically in the same cluster, increasing your performance 

Use the console to:
* create the instance: choose multiregional (expensive) or regional (cheaper), the name, number of nodes.
* create The tables: use a SQL query to create a schema
* insert/update/delete data inside the table
* Remove tables and instances
Straightforward, nothing complicated.

The complication will come when designing an application needed a spanner database, when comes to:
- data locality (nested tables or foreign keys)
- availabilty/scalability (number of nodes, multi-region vs mono-region)

#### MemoryStore
Based on redis to build a fast in-memory store to access data.

To be as fast as possible, put the Redis instance in the same zone as your resources that will access it.

Can be connected at appengine, compute engine, cloud functions, GKE...

To create redis instance:
```
gcloud redis instances create truar-redis-test --size=1 --region=europe-west1 /
    --redis-version=redis_4_0
```
To get information, like the IP to use to connect to the instance
```
gcloud redis instances describe truar-redis-test --region=europe-west1
```
Then, just to try, create a compute engine, (in europe-west1 region), and start storing data using telnet protocol
```
sudo apt-get install telnet
telnet 10.255.27.19 6379
PING
> + PONG
SET HELLO WORLD
GET HELLO
> + WORLD
quit
```
To remove the reddis instance
```
gcloud redis instances delete truar-redis-test --region=europe-west1
```
If you want to avoid setting the region for every command, use
```
gcloud config set redis/region europe-west1
```
Warning: if not specifying the zone, it picks one in your region.

#### Cloud dataproc

#### Cloud dataflow

#### Cloud Pub/Sub

### Loading data (e.g., command line upload, API transfer, import/export, load data from Cloud Storage, streaming data to Cloud Pub/Sub)

## 3.5 Deploying and implementing networking resources. Tasks include:

### Creating a VPC with subnets (e.g., custom-mode VPC, shared VPC)
A VPC is Virtual Private Cloud, allowing us to build our network the way we want.
By default, if not stated otherwise by the organisational policy, you can use the "default" vpc (which is the one I use everytime I deploy a resource)

A VPC :
* is a global resources (not bounded to a region or zone)
* Subnets are only regionals
* Control traffic from instances to instances using firewall rules
* Resources can communicate using IPv4 addresses
* Can be secured using IAM page
* Can be shared across your entire organization. Use IAM restriction to allow project and people creating subnets from the shared VPC
* Peer to Peer to connect different VPC
* VPC can be connected in hybrid environment using Cloud VPN or Cloud Interconnect

1 VPC network is a set of subnets (range of IP addresses)

* `Auto-mode VPC network`: create one subnet in each region (like default). You can also add more subnets in a region if you need it.
 The new IP ranges Google could create during its lifetime are automatically added to the this type of VPC.
* `Custom-mode VPC network`: create a VPC network without subnet, giving us full control. This is the recommended type in production,
as it makes sure you do not overlap IP addresses with VPN, or static IP addresses...

In a VPC, 4 addresses are not available:
* the network, gateway and broadcast (classic)
* the second-to-the-last address: Reserved by GCP for future use ... ?

#### Routes and firewall rules
Routes defines path for packets leaving instances (egress).

Every netwotk starts with a default route, to give the VMs access to the internet.
Subnet routes are used to send packets across VMs. each network has one default subnet routes. But can have more if have a secondary IPs ranges. 

##### Dynamic routing mode
* Regional: A router can only contact and send packets to a VM in its region. This has a better availibilty, 
since you need more routers and VPN to reach a machine in another region. If one router fails, the dynamic routing is able to properly
redirect traffic to the machine.
* global: A router can contact any VMs in the network. Less availability. Apparently, even more downside, but I am not sure yet.

#### Commands
To create an **auto-mode** VPC with a **regional** routing:
```
gcloud compute networks create truarvpcnetworkauto \
    --subnet-mode=auto \
    --bgp-routing-mode=regional
```
> Every subnets in the new VPC shared the same region IPv4 CIDR addresses than the default network

To create a **custom-mode** VPC
```
gcloud compute networks create truarvpcnetworkcustom \
    --subnet-mode=custom \
    --bgp-routing-mode=regional
```
 
Let's start a classic easy use case.
I create a new auto regional VPC:
```
gcloud compute networks create truarvpcnetworkauto \
    --subnet-mode=auto \
    --bgp-routing-mode=regional
```
I create 2 compute instances in this new network, in the europe-west1-b zone. 
> This will create 2 VMs with IP addresses in the range of the europe-west1 subnets automatically.
```
gcloud compute instances create instance-2 \
    --zone=europe-west1-b \
    --machine-type=f1-micro \
    --subnet=truarvpcnetworkauto

gcloud compute instances create instance-3 \
    --zone=europe-west1-b \
    --machine-type=f1-micro \
    --subnet=truarvpcnetworkauto
```
instance-2 = 10.132.0.2 | 35.195.44.179
instance-3 = 10.132.0.3 | 35.187.37.217
Let's try now SSH on instance-2
> Fail ! logic, I have no firewall rules, therefore, I can't connect to my machine.

I want to connect using SSH now. I should add a new firewall rule, SSH for my network
> In the VPC page, firewall rules section, add new rule > Ingress (incoming traffic), TCP: 22, Allow all type
```
ssh -i ~/.ssh/my-key 35.187.37.217

## Welcome to instance 3
ssh-keygen -t rsa -f ~/.ssh/my_key
# (copy the my_key.pub in the instance-2 allowed ssh public key)
ssh -i .ssh/my_key 10.132.0.2

## Welcome to instance-2
```

And now, SSH works !
With this, can my two machines communicate together using SSH ?
> Yes, except they don't know each other public key, so ssh id blocked, but they can communicate.

Is PING available ?
> No because there is no such rule, yet.

But now, all my machines are accessible over the internet. If I want to deny that, I could :
* create a new network, with a new subnet and allowing only IP from my europe-west1 CIDR
> I went onto the GCP console, add a new subnet to my truarvpcnetworkcustom and select a the Europe-west1 region
* 10.133.0.0/24 CIDR | No external IP
* I want only my internal VPC to connect to this VM... Is it possible ? Or do I need a VPN or something ? 
* With cloud router regional, that should do it...
* Name the subnet by the region, or the instance creation will not find it... it will be looking for a subnet whose name is the same as the selected region.
* Which in my cases, I didn't do, so I couldn't create my instance.
```
gcloud compute instances create instance-1 \
    --zone=europe-west1-b \
    --machine-type=f1-micro \
    --subnet=truar-europe-west-2

gcloud compute instances create instance-2 \
    --zone=europe-west1-b \
    --machine-type=f1-micro \
    --subnet=truarvpcnetworkauto
```
You can't share rules across network. A rules exists for a specific network.

2 VPC can't communicate, unless more configuration (peer to peer, VPN). 

With the dynamic routing, 2 instances can communicate inside the same VPC but in different subnets.

It is possible to apply a firewall rule to:
* instance running as a specific service account (only changeable when server is stopped).
* instance tagged with a special name (anytime), and a VM can have multiple tags. the most famous example is with
the http-server, where you can accept all request from outside. And a db-server, where you deny except from the inside.

If you want to prevent any instance access from an unknown person, you can choose not to associate an external IP (at creation, and when running also)

External IP addresses have two types:
* ephemeral: youn won't have the same one when you server starts again
* static: you keep the same one as long as you want (even after server reboot)

### Launching a Compute Engine instance with custom network configuration (e.g., internal-only IP address, Google private access, static external and private IP address, network tags)
### Creating ingress and egress firewall rules for a VPC (e.g., IP subnets, tags, service accounts)
### Creating a VPN between a Google VPC and an external network using Cloud VPN
### Creating a load balancer to distribute application network traffic to an application (e.g., Global HTTP(S) load balancer, Global SSL Proxy load balancer, Global TCP Proxy load balancer, regional network load balancer, regional internal load balancer)

Need to create a VPN
Need to create load balancer SSL / TCP / regional / internal

Internal Load Balancer is used to balance traffic inside the region where the load balancer is configured.
Use cases :
* Database access from your application. Configure a internal TCP load balancer among your instances
* Web application for internal client (in your VPC) only. use a Internal HTTP(S) Load balancer in this case

A global HTTP(S) Load balancer is perfect to balance the request from your client to your apps.
It contains a:
* forwarding rule to redirect traffic to a target HTTP proxy
* the target HTTP proxy uses a URL map to redirect traffic based on HTTP headers (/videos, /images) to the correct backend server
* backends servers, global, to balance traffic across your instances.

In most cases (HTTP, SSL, TCP LB) the IP from the client is lost. Only when it is simple a forwarding rule that the source is kept.
Otherwise, the proxy terminated the client connection and open a new one with the backend server.

To keep client IP, use the "PROXY mode", or use a TCP/UDP network loadbalancer (a LB in a single region).
If you use multi-region, then the LoadBalancer becomes a proxy, and the connection gets terminated.

Most of the times, we need all of this when we want to manage everything ourselves. By using the GCP products, you don't
have to consider this sometimes. 

When doing HTTP (layer 7), it is recommended to configure the HTTP LB as it is easier to configure redirection based
on HTTP headers (url, cookie, header...)
Otherwise, use the TCP/SSL.

SSL vs TCP : If you need to encrypt the request/responses between you and your client. It is possible to configure a SSL for the connection
between the client and your application, and to send a decrypted request to your backend (not recommended anyway).

## 3.6 Deploying a solution using Cloud Marketplace. Tasks include:

### Browsing Cloud Marketplace catalog and viewing solution details
In the console > MarketPlace, you can browse the catalog for solutions ready to deploy.

You can find everything that is managed by Google (app engine, compute, storage like firebase, filestore, Bigquery...)

Deploy in a VM many CMS solutions, Operating systems, developer tools, stack (elastic, lamp, django)

Also deploy containers, like jenkins, or jetty, kibana, grafana

Many databases also

### Deploying a Cloud Marketplace solution
Click on a solution, and then install it. It will create, depending on your choice, create a GCP resources.
For instance, deploying nginx deploys a compute instance. A wordpress also deplys a compute instance, with phpMyAdmin, Wordpress, MySQL...

## 3.7 Deploying application infrastructure using Cloud Deployment Manager. Tasks include:
The deployment manager is very useful to make sure you always deploy the same application for your project.
If you need 2 CE, and 1 BigTable, then create a deployment manager template to always those resources the same way.

You can create `template`: a reusable piece of yml that allow you to build complex deployment manager file more easily.

### Developing Deployment Manager templates
To develop this application, just create a `file.yml` containing properties.
The basic example is creating a compute instance vm. Here is the file `vm.yml`:
```
# For a list of supported resources,
# see https://cloud.google.com/deployment-manager/docs/configuration/supported-resource-types.
resources:
  - type: compute.v1.instance
    name: quickstart-deployment-vm
    properties:
      # The properties of the resource depend on the type of resource. For a list
      # of properties, see the API reference for the resource.
      zone: europe-west1-b
      # Replace [MY_PROJECT] with your project ID
      machineType: https://www.googleapis.com/compute/v1/projects/gcp-associate-cert-prep-truaro/zones/europe-west1-b/machineTypes/f1-micro
      disks:
        - deviceName: boot
          type: PERSISTENT
          boot: true
          autoDelete: true
          initializeParams:
            # See a full list of image families at https://cloud.google.com/compute/docs/images#os-compute-support
            # The format of the sourceImage URL is: https://www.googleapis.com/compute/v1/projects/[IMAGE_PROJECT]/global/images/family/[FAMILY_NAME]
            sourceImage: https://www.googleapis.com/compute/v1/projects/debian-cloud/global/images/family/debian-9
      # Replace [MY_PROJECT] with your project ID
      networkInterfaces:
        - network: https://www.googleapis.com/compute/v1/projects/gcp-associate-cert-prep-truaro/global/networks/default
          # Access Config required to give the instance a public IP address
          accessConfigs:
            - name: External NAT
              type: ONE_TO_ONE_NAT
```

### Launching a Deployment Manager template
To deploy and launch it, use:
```
cd deployment-manager/basic-example
gcloud deployment-manager deployments create quickstart-deployment --config vm.yml
```
To describe it:
```
gcloud deployment-manager deployments describe quickstart-deployment
```
Go in the console > Deployment Manager to check if the template has been deployed.

To delete it:
```
gcloud deployment-manager deployments delete quickstart-deployment
```

Best practices: Use python for template. Create template to get unit of deployment.

The `deployment-manager/more-complex-example` does more than the basic:
* Creates a load-balanced application with:
* A MySQL as a backend server, container, on a compute instance
* A NodeJS app, with a template, a instance group of size 2 and max scale of 20.
* A forwardrule, health check and target pool (nothing I never saw before)

To deploy it, do :
```
cd deployment-manager/more-complex-example/nodejs
gcloud deployment-manager deployments create more-complex-example --config nodejs.yaml
gcloud deployment-manager deployments delete more-complex-example --config nodejs.yaml
```

This is a really DevOps oriented tool. When you need to reproduce easily your environment. Clearly, it is an IaaC.
Great to keep all environment/projects lined up.

For CloudCMR, could be used for :
- Creating the database (Firestore)
- But, for appEngine, don't think it is useful.

# 4. Ensuring successful operation of a cloud solution

## 4.1 Managing Compute Engine resources. Tasks include:

### Managing a single VM instance (e.g., start, stop, edit configuration, or delete an instance)
Use `gcloud compute instances create my-instance-name`
### SSH/RDP to the instance
ssh the external IP, or, use the console and click on `SSH`
### Attaching a GPU to a new instance and installing CUDA libraries

### Viewing current running VM inventory (instance IDs, details)
`gcloud compute instances describe my-instance-name`
Or click on the instance name in the console.
### Working with snapshots (e.g., create a snapshot from a VM, view snapshots, delete a snapshot)
Snapshots are a backup of your persistent storage disk to ensure you can restore your data in case of a crash.
You can schedule snapshots to make sure your is saved at regular interval. 
The first snapshot is full and copy the entire disk. The other ones are smaller, as they only store the difference between the previous snaphshot and the current disk state.

Some snapshots best practices:
* Flush the data to the disk before taking a snapshot. Make sure everything is written, and then stop your app.
* Or, freeze or unmount the disk, to make sure the snapshot is reliable.
* Choose a snapshot time during off-peak period, to avoid latency on your apps
* If you often need to create an instance from a snapshot, make an image out of the snapshot, and use this image to create instance. 
This reduces the cost of network.
* If you don't need to save all your data, then create different disks and mount them. This way, you can reduce the size of your
snapshot if you need only to save a subsequent part of your data.

To daily saved a disk, create a daily schedule snapshots, then go to your disk configuration page, and attach the schedule snapshot to it.

You can create an image out of a snapshot, and use it to create new instances. to select your newly created images, create an instance,
and change the image (default is debian), to a new `custom image` and find the one you created. Be careful of the region (I guess). you could not find your image
if you are deploying an instance into a different region.

Schedule snapshots can be :
* hourly, daily or weekly.
* With a retention policy (default 14 days). It indicated the number of days you want to keep your snapshots before deleting them.
* Regional or multi-regional. a snapshot can be limited to a region, coming from an other one, but keep in mind the network cost when doing so.

When deleting a snapshot, the data contained in this snapshot are transferred to next one. It is a linked list of snapshot basically.
### Working with images (e.g., create an image from a VM or a snapshot, view images, delete an image)
In the console > Compute Engines > Images
In this page, you see all the available images you have in your project, and the default ones provided by gcp.

To create an image, click `Create an image`, then select :
* the name
* the source:
    * a disk: a disk created by one of your compute engine for instance, or one you created yourself.
    * a snapshot: when you saved one of your disk, choose a snapshot to create a new image
    * an image: create an image from another image
    * Cloud storage file : a file stored in your buckets
    * Virtual disk : A VMDK or other virtual instance (VHD) (require special roles: compute.admin & iam.serviceAccountUser)
    
In the main page, you can also delete the image you don't want to use anymore (not the default one).

You can also start the creation of an instance in this page. It just fill the main instance form page with he image you selected.

### Working with instance groups (e.g., set autoscaling parameters, assign instance template, create an instance template, remove instance group)
#### Managed instance group
An managed instance group is useful the manage a set of instance as a logical cluster, working together to achieve a functionality.

It is mandatory to create your instances the same way if you want a managed cluster instance. You need to have created an `instance template` to
make sure you create your instances the same way (for instance, with a http server, or postgresql database).

An instance template can be created using the `gcloud` but also the `console`.
An instance template specify almost everything like the instance creation):
* the machine type (f1-micro, n1-standard)
* The CPU and GPU if needed
* the boot device (with the image)
* the account service logged into the instance
* and among other optional things, you can either:
    * Past a shell content to install your instance at the creation: startup-script="#!/bin/sh..."
    * Past the link to a shell file (using the console, the file must be on the internet accessible, like a google bucket, or using the gcloud cli, the file can be on your fs)
    * console= startup-script-url=gs://BUCKET_URL
    
Then, if you want to create a manage group, go in the console, and create `New managed instance group`.
You will need to have created your template first.

Choose some configurations, like :
* the zone (classic). Is it a multiple zone or a single zone cluster ? (please note that the cluster needs to be in the same region at least)
* the instance template
* The autoscaling configuration. You can disable the autoscale, enable it always up (always more instances, but never less), or fully managed.
The autoscaling is based is based on some criteria:
    * CPU Utilization. At a threshold, create new VM
    * HTTP Traffic : increase instance of the HTTP traffic is to high (in percentage of its capacity)
    * Stackdriver monitoring metrics : A special metric in your stackdriver interface that will indicate when it is the best moment to autoscale your instances.
* Note that you can create multiple metrics. In case of high traffic with low CPU, you won't always autoscale, but your clients might by waiting for responses from your VM.
* Create or use an health check to have a loadbalancer avoiding not responding server

#### Unmanaged instance group
You can create also an unmanaged instance group to group VMs that doesn't need to share the same configuration.
Given the circumstances, it is possible, but prefer a managed instance group when possible.
You create a unmanaged instance group only after you have instance created. 

### Working with management interfaces (e.g., Cloud Console, Cloud Shell, GCloud SDK)
```
gcloud compute instances COMMAND : manage the instances
gcloud compute instance-groups COMMAND : manage the instance groups
```
`gcloud compute` can manage google resources :
* instances
* instances-groups
* images
* disks
* heath-check (special command for http(s)-health-check)
* templates
* networks
* regions
* snapshots
* load-balancer

But also execute actions like :
* connects SSH to a engine

Even if it is a single interface for `gcloud`, those resources are splitted across many console pages.

## 4.2 Managing Google Kubernetes Engine resources. Tasks include:

### Viewing current running cluster inventory (nodes, pods, services)
### Browsing the container image repository and viewing container image details
### Working with node pools (e.g., add, edit, or remove a node pool)
### Working with pods (e.g., add, edit, or remove pods)
### Working with services (e.g., add, edit, or remove a service)
### Working with stateful applications (e.g. persistent volumes, stateful sets)
### Working with management interfaces (e.g., Cloud Console, Cloud Shell, Cloud SDK)

## 4.3 Managing App Engine and Cloud Run resources. Tasks include:

### Adjusting application traffic splitting parameters
#### App engine
When using App Engine, you can split traffic across multiple versions of the same service using the console.
Deploy your application with maven or gradle plugin to enhance your deployment.

With the maven plugin, the traffic is automatically migrated to the new versions.

You can split traffic depending on the :
* client IP
* a cookie named "GOOGAPPUID"
* Random assignment

#### Cloud Run
As App engine, a Cloud Run service can split traffic across multiple versions. But there is less options. We can't choose (with the console)
on which criterias to split, unlike app engine.

### Setting scaling parameters for autoscaling instances

#### App engine
To manage the autoscaling parameters, add parameters to the appengine/app.yml with the parameters :
```yaml
automatic_scaling:
    max_instances:
    min_instances:
    min_idle_instances:
    max_idle_instances:
    # And others
    
    # To configure the autoscaling parameters:
    target_cpu_utilization:
    target_throughput_utilization:
    max_concurrent_requests: 
```

To see all possibilites: https://cloud.google.com/appengine/docs/standard/java11/config/appref
You can combine `target_throughput_utilization` with `max_concurrent_requests` to start new instances given a number of requests

You can also set a basic or manual scaling, if you want to build application based on things in memory, otherwise, don't.

#### Cloud Run
##### Fully managed
When creating a cloud run service, the Console interface provides an advanced settings in which you can configure:
* the container Port
* the container execution command
* The RAM (128M to 2G, or even more)
* The CPU (1 or 2)
* A request timeout 

On autoscaling, it seems that the configuration is limited to the number of requests per container instance. App engine seemed to have more configuration
for autoscaling (like CPU, or requests).

But it is more than enough.

You can also restrict the number of maximum instance for a service, but the minimum is set to 0.

I hadn't check every possibilities for app engine, but I guess that's pretty much the same.

Cloud Runs gives less information. It is like a small environment in GCP, as it has its own reporting, dashboard, you can't directly see the running instances, you can see them
with the dashboard

This configuration is very basic, and can leverage developer deployment. But is limited if you need more configuration.

##### Anthos (and kubernetes)
You need to have an anthos cluster started to manage your cloud runs in this cluster.

### Working with management interfaces (e.g., Cloud Console, Cloud Shell, Cloud SDK)
#### App Engine
App engine is linked to the stackdriver resources. You can access logs and others resources information, like CPU, incoming requests...
Every log of your applications are redirected to the console, which is catch by the stackdriver.
You can also create uptime check and alert

Be careful with app engine, without configuring the max autoscaling parameters, you can quickly loose control of your instances, and so the cost.

```
gcloud app instances list
gcloud app versions list
gcloud app browse --service="querkus-hello"
gcloud app create
gcloud app deploy ./to/app.yml
```

#### Cloud Runs

```
gcloud run deploy <service-name> --image <image_name>
gcloud run revisions list --region=europe-west1 --platform=managed
```

Very easy to manage through the console. I guess must be the same through the `gcloud` CLI.

## 4.4 Managing storage and database solutions. Tasks include:

### Moving objects between Cloud Storage buckets
### Converting Cloud Storage buckets between storage classes
### Setting object life cycle management policies for Cloud Storage buckets
### Executing queries to retrieve data from data instances (e.g., Cloud SQL, BigQuery, Cloud Spanner, Cloud Datastore, Cloud Bigtable)
### Estimating costs of a BigQuery query
### Backing up and restoring data instances (e.g., Cloud SQL, Cloud Datastore)
### Reviewing job status in Cloud Dataproc, Cloud Dataflow, or BigQuery
### Working with management interfaces (e.g., Cloud Console, Cloud Shell, Cloud SDK)

## 4.5 Managing networking resources. Tasks include:

### Adding a subnet to an existing VPC
### Expanding a subnet to have more IP addresses
### Reserving static external or internal IP addresses
### Working with management interfaces (e.g., Cloud Console, Cloud Shell, Cloud SDK)

## 4.6 Monitoring and logging. Tasks include:

### Creating Stackdriver alerts based on resource metrics
### Creating Stackdriver custom metrics
### Configuring log sinks to export logs to external systems (e.g., on-premises or BigQuery)
### Viewing and filtering logs in Stackdriver
### Viewing specific log message details in Stackdriver
### Using cloud diagnostics to research an application issue (e.g., viewing Cloud Trace data, using Cloud Debug to view an application point-in-time)
### Viewing Google Cloud Platform status
### Working with management interfaces (e.g., Cloud Console, Cloud Shell, Cloud SDK)

# 5. Configuring access and security

## 5.1 Managing identity and access management (IAM). Tasks include:

### Viewing IAM role assignments
### Assigning IAM roles to accounts or Google Groups
### Defining custom IAM roles

## 5.2 Managing service accounts. Tasks include:

### Managing service accounts with limited privileges
### Assigning a service account to VM instances
### Granting access to a service account in another project

## 5.3 Viewing audit logs for project and managed services.