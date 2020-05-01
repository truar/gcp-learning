# Elastic cloud - Scaling and Automating

## Cloud VPN

Connects your infrastructure to the Google infrastructure using a VPN.
* IPSec VPN tunnel
* Low volume of data
    * Encryption on both sides
* 99.9% SLA
* Supports 
    * static
    * dynamic routes (Cloud Router)
    * Site to site VPN
    * IKEv1 and IKEv2 ciphers

Does not support a client VPN use cases (like pulse ?)

To connect On-premises with Google Cloud, you need:
* to configure your Cloud VPN gateway on-premise VPN gateway and to VPN tunnels
* Cloud VPN gateway is a regional resource (regional external IP address)
* On-premise VPN gateway can be
    * physical device in data center, or software based VPN offering in another Cloud providers network
* VPN tunnel connects the VPN gateway and transfer the encrypted data
* To establish a connection between 2 VPN gateways, you must create 2 VPN tunnels
    * Needs both tunnels to communicate
    * Maximum Transmission Unit (MTU) is 1460 bytes... Not sure to understand what it means
        * Due to the encryption, you can't pass packets greater than 1,460 bytes (is it ?)

Cloud Router:
* Manages routes from Cloud VPN tunnel using boarder gateway protocol (BGP).
    * Allow to change routes without changing the tunnel configuration
* Use cases: adding more subnets in GCP and on-premises automatically, growing network...
* To setup BGP, an additional IP address has to be assigned to each end of the VPN tunnel
    * Link local IP ADdresses: 169.254.0.0/16
    
Labs:
```
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" target-vpn-gateways create "vpn-1" --region "us-central1" --network "vpn-network-1"
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" forwarding-rules create "vpn-1-rule-esp" --region "us-central1" --address "35.184.88.133" --ip-protocol "ESP" --target-vpn-gateway "vpn-1"
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" forwarding-rules create "vpn-1-rule-udp500" --region "us-central1" --address "35.184.88.133" --ip-protocol "UDP" --ports "500" --target-vpn-gateway "vpn-1"
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" forwarding-rules create "vpn-1-rule-udp4500" --region "us-central1" --address "35.184.88.133" --ip-protocol "UDP" --ports "4500" --target-vpn-gateway "vpn-1"
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" vpn-tunnels create "tunnelt1to2" --region "us-central1" --peer-address "34.76.101.215" --shared-secret "gcprocks" --ike-version "2" --local-traffic-selector "0.0.0.0/0" --target-vpn-gateway "vpn-1"
gcloud compute --project "qwiklabs-gcp-03-609b1efc130c" routes create "tunnelt1to2-route-1" --network "vpn-network-1" --next-hop-vpn-tunnel "tunnelt1to2" --next-hop-vpn-tunnel-region "us-central1" --destination-range "10.1.3.0/24"
```

The machine in the network covered by VPN1 will have a new routing rules configured:
* the destination is the other subnet IP addresses CIDR (subnet 2)
* Il will go through the tunnel 1 to 2.
* To communicate, tunnels must have external IP addresses, that is the reason why we need to create one IP address per tunnel
    * Subnet is regional, so naturally, external IP of the tunnel must be in the same region as the subnet

This avoid giving all machines external Ip addresses, that anyone can access

## Cloud interconnects and peering

|   | Dedicated : Direct connection (physical) to google's network| Shared : The partner is in charge of giving you the connection |
|---|-----------|--------|
| Layer 3 : Access to G-suite, APIs, Youtube...| Direct Peering | Carrier Peering |
| Layer 2 : VLAN IP addresses RFC 1918 | Dedicated Interconnect | Partner interconnect |

## Cloud interconnect
Dedicated interconnect provides:
* direct physical connection with Google's network
* Transfer large amount of data with a lower cost than paying for the internet bandwith
* Provision a cross-connect, in a common colocation facility
* Configure a BGP session over the interconnect between Cloud Router and the onpremise router.
* 99.9% up to 99.99% SLA

The colocation facility are splitted across the world. If you are not near one the location, this is when we consider a partner.
* Seattle, Salt Lake City, San Jose, Rio de janeiro, Paris, Marseille, Kuala lumpur...

Partner interconnect provides:
* connectivity between your VPC network and your on-premise network
*  Work with the supported service providers.
* Have existant physical connection, that are available to clients.
* 99.9 to 99.99% uptime SLA (between Google and the service provider)

With any VPN connections, you can connect the VMs internal IP addresses to communicate.
The differences are the connection capacity and requirements for using a service.

IPSec VPN:
* Encrypted tunnel over public internet
* 1.5 to 3Gbps per tunnel
    * Scale tunnel to scale capacity
* On premises VPN gateway (a VPN device)

Dedicated interconnect:
* 10Gbps per link (minimum capacity)
    * Can have up to 8 links
* BETA: 100Gbps (with 2 links)
* Connection in google colocoation facility

Partner interconnect:
* 50Mbps to 10Gbps

Start with Tunnel, then move on to a more enterprise approach.

## Peering

* Access to google and google properties
* Direct peering between Business network and Google's
* exchange internet traffic between your networks and Google's
* Done by exchanging BGP routes between Google and the peering entity
* Reach all services, including the full suite of Google Cloud plateform
* Do not have a SLA
* Needs to satisfy peering requirements

Gcp Edge Point of Presence (PoPs)
* Connects Google to the rest of the internet
* 90 internet exchanges and over 100 interconnection facilities around the world
* Google peering DB entries

Once again, is away from one of this location, use a Partner.

They both provide Public IP addresses access to all google services

Direct Peering:
* Dedicated direct connection
* 10Gbps per link
* Requirements: Connections in GCP PoPs

Career Peering:
* Peering though service provider
* Varies based on partner offering
* Requirements: see the Service provider

## Choosing a connection

* Do you need access to Google's Suite services ?
    * If yes, then do you meet directs peering requirements ?
        * If yes, then Direct peering
        * If no, then Career peering
    * If no, if you want to reach your network to GCP
        * If yes: can you meet the GCP colocation facilities ?  
            * If yes: then dedicated connection
            * If no: Do you have modest bandwidth usage, short duration, trials ?
                * If yes: Cloud VPN
                * If no: Partner connection
                
## Shared VPC networks and VPC peering

Shared VPC allows an organization to connect resources from multiple projects to a common VPC network.
* Same organization
* Secure communication
* Efficiency
* 4 projects (or more) can share the same common VPC, and communicate using the internal IP address
* Only the host is reachable from the outside. The backend server are invisible for outside of the network

Requirements: A project must be the host, and then attach more projects to it

VPC network peering
* RFC 1918 connectivity across 2 VPC networks
* Regardless of their projects or organization

Example: 2 organizations, differents nodes, different resources. In order to connect them:
* the producer network admin needs to peer with the consumer network
* The consumer network admin needs to peer with the producer network
* When both are created, the session becomes active, routes are exchanged. 
    * VMs can communicate privatly using their internal IP addresses
* decentralized / distributed approach.
* No latency (as internal use)
* No cost drawbacks

Shared VPC:
* Not accross organizations
* Not within project
* centralized network admin

VPC Network Peering:
* Across organizations
* Within projects (network can be)
* Decentralized network admin => biggest difference

## Managed instance groups

* A group of identical instances deploying together 
* Control them as a signel entity using a template
* Instance groups can be resized. Scale up and down automatically
* Works with loadBalancing to balance traffic in the groups
* Manager ensured all instances are RUNNING
    * If an instance is deleted, stopped, or crashes, the manager automatically recreates an instance using the template
    * Identify and recreate unhealthy instances
    * ensure that it is optimal
* Zonal or regional resource
    * Recommendation: Use regional resources. Higher fault tolerance by running the application in multiple zones
    * Protects againts the scenario where an zone in malfunctioning...

1. Need an instance template (like the compute engine creation form)
2. Then creates group of N instances
    * Zonal vs regional
    * Ports allowed
    * Load balancer ?
    * Instance template to use
    * Autoscaling parameters
    * Health check to determine healthy instances to redirect traffic
3. Create instances with the templates
    
## Autoscaling and healthchecks

* Dynamically adjust (add/remove) instances 
    * Increases in load
    * Decreases in load (reduce cost)
* Autoscaling policy
    * CPU utilization
    * Load balancing capacity
    * Monitoring metrics
    * Queue-bases workload (cloud pub/sub)

Use cases: Threshold CPU utilization 75%
* 2 VMs, 100% and 85% CPU utilization
    * Creates new VMs to balance the load to meet the criteria
        * 3 VMs: 60, 60 and 65
    * Keep it that way as long as we are under the threshold
    * Once the load is lower, it decreases the instances as long as the criteria is meet

Monitoring ?
* A graph is presented when cliking on a group
* CPU over the last hours by default
* can change the timeframe and visualize networks or disks
* Practical to know how to configure autoscaling policy
* If using stackdrivers, use notification channel to get alerts

Healthcheks:
* very similar to uptime checks in stackdriver
* Define a protocol, a port and a health criteria
    * Check interval: how often to check wheter an instance is healthy ?
    * Timeout: How long to wait for a response ? 
    * Healthy threshold: How many successfull attempts are decisive (to consider the instance healthy) ?
    * Unhealthy threshold: How mnay failed attempts are decisive (to consider the instance un-healthy) ?

## HTTP/S global loadbalancing

Layer 7, application layer, deals with the actual content of each message allowing for routing based on the URL

* Global loadbalancing for HTTPS request
* Use only one IP address for your application, which simpliifies DNS setup
* Balance HTTP (80) and HTTPS (443) across multiple backend and multiple regions
* Supports both IPv4 and IPv6 clients
* Is scalable, no prewarming, enables content based and cross regional load balancing
* Configure URL maps to map URLs to instances, and other URLs to other instances
* Requests are redirected to the closest available instance

HTTPS load balancer architecture:
* Global forwarding rule: redirect Internet packet to a target HTTP Proxy
* Target PRoxy: checks the URL against the URL map to determine the appropriate service
    * Rules like: www.example.com/videos -> audio files instance groups
    * www.Example.com/audios -> video files instance groups
    * Based on solving capacity, zone and instance held of its attached backend

Backend services:
* Contains a health check
    * Like for the managed group. Avoid unhealthy instances to receive traffic
* Session affinity
    * Default: round robin algorithm
    * Overriden with session affinity (keep the client to the same machine based on the session)
* Timeout setting
    * Wait before considering the request a failure
    * Is a fixed timeout, not an idle
* Backends can contain:
    * An instance balanced group (managed or unmanaged)
    * A balancing mode (CPU Utilization or Request Per Second)
        * How to determine when the backends is at full usage
    * A capacity scaler (ceiling % of CPU/Rate targets)

Changes are not instantaneous

## HTTP Loadbalancer example
Create as many backend services as you need, given your needs
* 2 backend services if you redirect to different backend given the URL

* Global HTTP Proxy
    * Target HTTP Proxy (using the URL Map)
        * Global backend service (use the regional backend configuration to redirect traffic)
            * Traffic goes to instances

## HTTPS Load balancer

* Target HTTPS proxy
* 1 signed SSL certificate installed
* Client SSL session terminates at load balancer
* Support QUIC transport layer protocol

SSL certificates
* Create an SSL certificate resource
* Up to 10 SSL certificates (per target proxy)

## SSL Proxy Load balancing

* Encrypted non http traffic
* Terminates SSL sessions at load balancer layer
* IPv4/6
* Benifits
    * Intelligent routing: Can route to backend server where there is capacity
    * Certificate management: Self signed certificate on the instance
    * Apply security patching to keep the server safe

The traffic between the proxy and the backend can use SSL or TCP, but SSL is recommended

## TCP proxy balancer

* Unencrypted non HTTP traffic
* Terminates TCP session at load balancing layer
* IPv4/6
* Intelligent routing
* Security patching

## Network loadbalancing

* regional, non-proxied load balancing
    * Traffic is passed through the load balancer
    * Balanced inside the same region only
* Forwarding rule (IP protocol data)
* UDP / TCP / SSL traffic on port not supported by SSL / TCP proxy
* The backend can be:
    * template based instance
    * Target pool
        * A group of instances that receive incoming traffic from forwarding rules
        * the loadbalancer picks an instance from the target pool based on hash of the source IP and port, and destination IP and port
        * Only for forwarding rules handling TCP / UDP traffic
        * 50 target pools per project
        * 1 health check per target pool
    
## Internal load balancing

* Regional, private load balancing
    * Only accessible via the internal IP address of the machine in the same region
    * Front end to private backend instances
    * Stay inside VPC network or region
* TCP / UDP traffic
* Reduced latency because all load balanced traffic stay within Google's network
* Software defined, fully distributed load balancing

Comparison of Proxy versus Internal LB
* Proxy
    * 2 connections: client -> proxy | proxy -> backend
    * The LB (proxy) chooses the backend service to redirect to
    * Has its own IP address used by the client
* Internal
    * Lightweight loadbalancing based on top of Andromeda
    * Software based that delivers traffic directly from client to the backend instance

Use case:
* Client requesting Global Load balancer
    * Balancing requests to multiple regions
* 3 backend servers (3 regions), each their own compute instances for
    * The application
    * The database tier
* The applications communicate with the DB using an internal load balancer
* Simplifies security, and network pricing, and avoid SPOF

## Choosing the loadbalancer

* Support for IPV6 clients
    * HTTPS, SSL proxy and TCP proxy load balancing
    * Handle IPv6 from user, and IPv4 to your backend
    * LB acts as a reverse proxy
        * terminates IPv6 connection, and starts an IPv4 connection
        * Response with IPv6 to the client

Global Versus Regional LB
* HTTP/S traffic -> HTTP/S LB
* Otherwise: TCP or UDP Proxy
External vs Internal LB
* Internal supports bith TCP and UDP traffic
* BETA: Intenal HTTPS service

# Infrastructure Automation

## Deployment manager

* GCP console to get familier with the resources you want to create
* Cloud Shell when you are more confortable with the resources and want to go faster
* Deployment manager to take it to a all new level

* Is an infrastructure deployment service, create resources for us. Declarative way
* Repeatable deployment process, just with one click to delete or create
* Declarative approach => Specify what configuration should be, and let the system figure out the steps to take
* Focus on the application: defines the set of resources for the application
* Parallel deployment, which makes deployment faster (except if using link between resources (which you have to))
* Template-driven: re-use parts of code to enhance your others deployment code
* Uses the underlying API to deploy resources (everythings we saw so far)
* Template: Jinja or python

Example:
* Defines a VPC resource. A resource requires
    * Name : can be an invariant variables to get the name more generically, with an env variable
    * Type : API for VPC network: compute.v1.network
    * Properties
        * AutocreateSubnetworks: true

* Defines a Firewall rules
    * type: compute.v1.firewall
    * properties
        * network: {{ properties["network"] }} -> Is a template property
        * SourceRanges : 0.0.0.0/0
        * allowed:
            * IPProtocol: {{ properties["IPProtocol"] }} -> Is a template property
            * ports: {{ properties["Port"] }} -> Is a template property
            
* Top level configuration file using YAML
    * Importing templates with want to use
    
```yaml
imports:
- path: autonetwork.jinja
- path: firewall.jinja

resources:
- name: mynetwork
  type: autonetwork.jinja

- name: mynetwork-allow-http
  type: firewall.jinja
  properties:
    network: ${ref.mynetwork.selfLink}
    IPProtocol: TCP
    Port: [80]
```

* Can also use Terrafom, Chef, Puppet, Packer

```
gcloud deployment-manager deployments create dminfra --config=config.yaml --preview
gcloud deployment-manager deployments create dminfra --config=config.yaml
gcloud deployment-manager deployments delete dminfra
```

## GCP Marketplace

* Deploy production-grade solutions for third party that have already created their own deployment configurations based on deployment Manager
* Single bill for GCP and third-party services
* Manages solutions using Deployment Manager
* Notifications when a security update is available
* Direct access to partner support

Covers GCP fee, but not the license required for some third party solutions

## Managed Services

Eliminates the need of managing the infrastructure on our own, and outsource a lot of administrative and maintenance overhead to Google

### BigQuery
* Serverless highly scalable cost effective Cloud data warehouse
    * No infrastructure => Focus on writing code
* Petabyte scale
* SQL interface
* Very fast
* Free usage tier
* Can process 100billions in less than 1 minute
* Access via GCP console, shell `bq` or REST API for .NET/Java/python

### Cloud Dataflow
* Managed service for executing a variety of data processing patterns
* Transforming and Enriching data in stream and batch mode with equal reliability and expressiveness
* Open source programming using apache Beam
* Intelligently scale to millions of QPS
* simplified via SQL, Java or Python in Apache Beam SDK
    * Provide a set of windowing, sessions analysis primitives
    * ecosystem of source and sink connector
* Coupled with stackdriver, to set up priority alert and notifications to monitor the pipeline and quality of the data

Example:
* Sources:
    * Cloud Pub/sub, Cloud Datastore, Apache Avro, Apache Kafka
    * Stream or Batch
* Transformation using Cloud Data Flow
* Sink
    * Cloud Bigquery, DataStudio, third party tool (Data warehouse)
    * AI Plateform (Predictive Analysis)
    * Cloud BigTable (Caching & Serving)

### Cloud Dataprep
* Serverless, works at any scale
* Data preparation (exploring, cleaning, preparing structured and unstructured data) for analysis reporting and Machine Learning
* Suggest ideal data preparation
    * Don't have to write code
* Focus on data analysis
    * Automatic schema, datatypes possible joins and anomaly detection => Skip time consuming Data profiling
* Integrated partner service operated by Trifacta
* No upfront software installation

Example:
* Sources: Bigquery, Cloud storage, File Upload
* Preparation
    * Using CouldDataPrep
    * Injecting prepared Data into CloudDataFlow
* Analysis tools, like BigQuery/ML, Google Data studio, PartnerBI products, AI platform...

### Cloud Dataproc
* Fully managed Cloud Service
    * Runs Apache Spark and Hadoop clusters on a simpler way
    * Pay for the resource you use with per second billing
    * Reduce even more by using preemptible instance
* Super fast to start scale, and shutdown
    * Takes 90 seconds versus 30min for an on-premise installation
* Integrated with others GCP managed services, like BigQuery, BigTable, Stackdriver logging and monitoring
* Create cluster easily depending on your needs
* Based on known stack, so you don't have to learn anything new when migrating to GCP services

Dataproc and DataFlow can both be used for data processing, and there's overlap in their batch and streaming capabilities.

How do you decide which one you can use ?
* Dependencies on specific tools or packages ? 
    * If yes -> Cloud Dataproc, as you have more configuration available
    * If No ->
        * Do you favor DevOps approach ?
            * If yes -> Cloud Dataproc
            * If No -> Cloud Dataflow