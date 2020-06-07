# Reliable Google Cloud infrastructure: Design and Process

## Courses overview
* Architecture and coursed will be microservice based.
* Create and design an application
1. Defining services
2. Microservice design and Architecture
3. DevOps Automation
4. Choosing Storage Solutions
5. Google Cloud and Hybrid Network Architecture
6. Deploying Applications to Google Cloud
7. Designing Reliable Systems
8. Security
9. Maintenance and Monitoring

## Case study
My case study: Cloud CMR

My application :
* manages members to an association thanks to volunteers, others members of the association
* a sale module when members buy article (ticket, annual fee...) to cashier
    * With this module comes up a tool to help the cashier counting the deposit at the hand of the day
* A school module, where you can have teachers teaching to students
    * With a course scheduler, students management
    * the teacher can know what students are in his class
    * At the course day, he can call everybody and checking if everybody is here
* An event programmer, in which you can schedule your future events (party, competition across members)

Main features:
* An office-member can register, search, delete and update other members information
* A cashier can sell articles to a member
* School creation (ski, rock-climbing...)
* Event management and organization, with a global and shared planning
* Sales analysis

Typical users:
* OfficeMember
* Cashier
* Cashier supervisor
* School administrator
* Teachers
* Event administrator

## Defining services
* Describe users in terms of roles and personas
    * these users will help define and refine user stories
* Write qualitative requirements with user stories
    * Example of business requirements
        * Accelerating the pace of software development
        * Reducing capital expenditure
        * Reducing time to recover from incident
* Write quantitative requirements using KPI
* Use SMART criteria to evaluate your service requirements
* Determine appropriate SLOs and SLIs for your services

## Requirements Analysis and Design
Qualitative requirements define systems from the user's point of view:
* Who (users, developers, stakeholders ?) -> who is impacted by the system, directly and indirectly
* What -> what does the system do ?
* Why -> Why is the system needed, useful ?
    * Without a clear understanding, extra requirements will be added all the time
* When -> helps determine a realistic timeline and help contains the scope
* How -> helps determine a lot of the non-functional requirements
    * How many users the system needs to support concurrently ?
    * Where will be located the users ?
    
Roles represent the goal of a user at some point and they enable the analysis of a requirement in a particular context.

Roles are not people or job title. It is an actor on the system.
* People can play multiple roles
* A single role can be played by multiple people
* can be a microservice system, accessing another system

Roles should describe a users objective
* What does the user want to do ?
* "User" is not a good role (everyone is a user)

Examples of Roles
* Shopper
* Account holder
* Customer
* Administrator
* Manager

Brainstorming: 
* First: create an initial set of roles
* Identify overlapping roles, related roles, and group these together
* Consolidate the grouped roles, the aim is to remove duplication
* finally, refine the roles including the internal and external roles, and the different usage patterns
    * Provide little information, such as users expertise on the domain,
    * or frequency of use of the proposed software
* => provide structure and brings focus to the task

A good thing is to associate a "Persona" to a role:
* helps the architect to think in terms of users of the system and gathers many requirements
* Often, a role has multiple personas
* For instance, for the same role "Cashier", a persona will want something more automated, which can affect latency, hence service design
    * another Persona "Cashier" would better likes to have really quick feedback on what he does... Which implies more data checks during the input, hence impact the design (network interactions, latency...)
* Helps developer to think "What would Jocelyn would want here ?"

User stories describe one thing a user wants the system to do:
* As a "user", I want "something" so that I can "do this particular action"
* Gives a title that describes its purposes
* Write a short one sentence description
* Specify the user role, what they want, why

A story must be INVEST:
* Independant: avoid problems with priorization and planning
* Negotiable: not written contracts, but are used to stimulate discussions between customer and 
developers until there is a clear agreement, they add collaboration 
* Valuable: Why is the story useful ?
* Estimable: if not, indicates a missing details or story too large 
* Small: fast feedback from the users, helps keep the score small, less ambiguous
* Testable: Verify that the stories has been implemented correctly


## Activity: Analysing case study

Roles with some possibles actions/features
* Member editor:
    * Create/Edit/Search Member
* Member Administrator (inherits editor):
    * Import member from FFS
    * Delete member
* Teller:
    * Open/Close sale session
    * Sell articles to members
* Teller supervisor:
    * Modify closed session
    * Check Teller session
* Accountant:
    * Check final balance
* Teacher:
    * Create/Modify Course
    * Affect students
    * Schedule course
* School administrator:
    * Create/modify/delete school
    
Persona:
* Alice is a very strict person, who likes when things are in order. She likes when
she can quickly access the information she is looking for, because she is very busy.
She likes to deal with the problems as soon as they appear. Above all, she is a great team player
and doesn't hesitate to give a hand any time it is possible

* Bob loves his job. He used to be a formal project director, and know how this field works.
He thinks that feedback are the most important thing when beng part of a team member, 
and he expects the others, and the tool he uses daily to do so. He has a kid who wants to be part of a ski school, and is ready to commit
to give him what he wants. He is an old fashioned guy, and does not want to be stressed anymore.
An application must be easy, and must help him in his daily tasks.

* Charles is a new comer, who likes when things are as fast as he is. He doesn't like waisting his time
and think that every minute is precious. He doesn't like when the application does not respond to its input,
and does not hesitate to span an action if he feels nothing is happening.

* David is has been a ski instructor for the last ten years. He likes new technology, and share his photos with his friends.
He also like to take photos of the ski during the day to share with their parents, so that they can see their kids.
Before every lessons, he always make sure that all the students are present. But too often, he forgets his paper with kids name on it,
and it is hard to know what kids are missing sometimes.

User story:
* As a Teller supervisor, I want a dashboard displaying the information on the sold articles for the sessions, in order to quickly anticipate the need of actions, 
like ordering a new bus if we sold more tickets than expected.
* As a Teller supervisor, I want a dashboard to display the information about the running sales to see if we are matching the expectations in term of turnover.
* As a School director, I want to create my own school to manage it more easily
* as a school director, I want to create my teachers that will give courses in my school in order to manage my school
* As a teacher, I want to create my own class in order to manage its content
* As a teacher, I want to schedule my course to better fit my agenda
* As a teacher, I want a quick access to my current course to make sure everybody is present before I go on my class

Do the persona:
* Alain est très impliqué dans la vie de l'association. En tant qu'ancien chef de projet informatique, il a réellement envie
d'aider l'association et les bénévoles, en leur proposant des améliorations de leur quotidien. Il est à l'aise avec l'utilisation
d'une application web et mobile, et image très bien les avantages que pourraient leur apporter un nouveau système de gestion de leurs adhérents.
Parfois, il en fait un peu trop, et va trop loin dans une fonctionnalité, au détriment des besoinds vraiment important.

* Laurence est l'informaticienne de l'association. Elle a repris leur ancien système pour se l'accaparer et le faire légèrement évoluer.
Elle serait ravie de disposer d'un nouveau système, mais celui-ci doit être plus fiable que l'existant, et vraiment simplifier la vie des adhérents.
A chaque évolution qu'elle fait dans le système existant, elle veut que cela se retrouve dans le nouveau, ce qui n'arrête pas d'ajouter des fonctionnalités,
pas forément indispensable. Elle est très investie dans la vie de l'associations, et c'est vers elle qu'il faut se tourner pour faire les premiers tests

* Florent est un professeur de ski depuis longtemps. Il aime donner les cours aux enfants le samedi, et aux adultes le dimanche. Vu qu'il a plusieurs cours
par semaine, il a besoin d'un système qui l'aide à centraliser toutes les informations. Faire un suivie des élèves est important pour lui, et il 
aimerait que le nouveau système l'aide dans ce sens. C'est également une des personnes qui s'occupent des données de l'application existante, et il en a marre
d'avoir à gérer des données dupliquées à travers différents volumineux fichiers Excel, cela lui fait perdre du temps. Il ne faut pas oublier que Flo est bénévole
et que passer ces vendredi soir à gérer les fichiers n'est pas quelque chose qu'il a envie de faire tout le temps.

## KPI and SLI
* Key Performance Indicators
* Service Level Indicators

It is important to know what we measure, why and how we measure it. Commonly, it must be respect the most frequent constraints:
* Time
* Finance
* People

Then we consider what we achieved, given the type of the system

| Measure | User facing system | Data storage system |
|---------|--------------------|---------------------|
| Latency | Response time | Data write/read time |
| Availability | Response OK | Data here when we need it |
| Throughput | Number of request handled |  |
| Durability |  | failure recovery |

KPI are metrics used to measure success, and can be categorized in two categories:
* Business KPI
    * Are a formal way to measure business values such as ROI in relation to a project or a service
    * Earnings before interests and taxes (EBIT)
    * Employees turnover
    * Customer churn
* Technical KPI
    * Page views
    * User registrations
    * number of checkout

As an architect, it is important to know how the business measure success.

KPI indicates whether you are on track to achieve the goal. A KPI is different than a goal.

A goal is the outcome or result you want to achieve. To be most effective, a KPI must go with a goal.

* For each goal, define KPI to monitor and measure progress
* For each KPI, define targets for what success looks like.

Example: 
* goal = Increase turnover for an online store
* KPI = percentage of conversions on the website

KPI must be SMART:
* Specific: User friendly is not specific. But Section 508 accessible is 
* Measurable: Vital. are we moving toward or away from the goal
* Achievable: 100% conversion is not achievable
* Relevant: Does it matter to the user ? Will it help achieving the goal
* Time-Bound: Hours, Days, Weeks, Month, Years... ?

Service Level Terminology:
* SLI: is a measurable attribute of a service. A KPI (ex: latency, throughout, durability, availabilty)
* SLO: is the number of the goal you want to achieve for a given SLI for a given duration. 95%, 99% availability ?
* SLA: is the binding contract providing the customer compensation if the service does not meet the specific expectations.
    * SLA is a more restrictive versions of the SLO 

We need to understand what the users want to know what to measure.

* Fast response time is not measurable
* HTTP Get requests that respond under 400millis aggregated per minute
* highly available is not measurable
* Percentage of successfull requests over all requests aggregated per minute is measurable.

Be careful, indicators must be measurable, but the way they are aggregated needs careful consideration.

Using average to estimate latency can hide the edge case, for the people that takes a lot longer to respond. 
Prefer a percentile approach, like the 99th, which shows the worst-case scenario. The 50th percentile just indicate a typical case.

## SLO and SLA
Uptime checks every 10 seconds aggregated per minute => Gives a percentage of the successfull request over a minute.

Objectives are vital, and need to be achievable:
* 100% availability is not realistic, and also way to expensive.
* 99.999% is achievable, but consider your own constraints (financial) as it is really expensive
* 99% may be the best compromise.

It is better to start with "low" or realistic SLO, and then move toward better solution

Other use cases: 
* SLI: HTTP Post photo uploads complete within 100ms aggregated per minute
* SLO: 
    * 99% not realistic if users are using mobile, and might be overkill
    * 80% seems reasonable

You can define graduate SLOs:
* 90% of HTTP GET calls will complete in less than 50ms
* 99% < 100ms
* 99.999% < 500ms

Tips for determining SLOs
* Don't make them too high. Begin slow, and improve as you learn more about the system and the users. Keep them simple and try to achieve.
    * The goal os to have as low as possible to make the users happy
* Avoid absolute values. 100% availability is nor achievable, nor useful in many cases, and will result with higher costs.
* Minimize SLOs. Don't make too much. Those help the team to focus the effort on things that are really valuable, to the users or the system
    * Reflects what the users care about
    * SLO too strict: Too ambitious product. SLO too relaxed: poor product
    
SLA is a business contract between the service provider and the user.
* Penalty will apply when SLA are not met.
* Compensation can be given to users
* Not all services should have an SLAs, but all should have SLOs
* SLO threshold >= SLA threshold
    * If the team's effort are to satisfy the SLO, there is a great probability that the SLA will not be met...
    * That's why SLA should always be lower or equals to SLO

Example:
* SLI: HTTP responses (200) latency (response time)
* SLO: latency 99% of HTTP responses must be < 200ms
* SLA: latency 99% of HTTP responses must be < 300ms
    * SLA is more relax than SLO, which is the position we always look for
    * There is compensation if the system does not meet the criteria of the SLA
    * But it is okay if the system does not achieve the SLO. It is an objective the team is working on
    
### Activity study: define SLI and SLO
Cloud CMR : what could be the SLI ?

Feature: 
* As a Teller supervisor, I want a dashboard displaying the information on the sold articles for the sessions, in order to quickly anticipate the need of actions, 
like ordering a new bus if we sold more tickets than expected.
    * SLI: Latency - Response Time when receiving request
    * SLO: Response time must be under 100ms aggregated per minute for 90% of request
* As a member administrator, I want to import a file containing all members I need to create and update in order to keep synchronize with the national members database
    * SLI: 
        * Latency - Request time when receiving last packet
        * Error rate: Upload errors measured as a percentage of bulk uploads per day by custom metric
    * SLO:  
       * Latency - Request time must be under 500ms aggregated per minute for 90% of request
       * Error rate < 0.01 %
* As an accountant, I need to keep files to keep track of every transaction that has occured in the system in order to respond to a trimestrial audit
    * SLI: 
        * Durability - The files needs to be stored and recovered in case of failure
        * Availability - The files needs to be downloadable when needed
    * SLO: 
        * Durability - > 99.999%
        * Availability - The files needs to be 99% available
* As a Teller supervisor, I want the system to handle multiple requests in parallel from my team in order to make them work in a good condition, and maximize the number of sale
    * SLI: 
        * Throughput - The system needs to handle multiple requests in parallel
        * Availability - fraction of 200 vs 500 HTTP responses from API endpoint measured per month
    * SLO: 
        * Throughput - handling 10 requests in parallel every second
        * Availability - Available 99%
    
## Microservices Design and Architecture

* Decompose monolithic application into microservices
* Recongnize appropriate microservces boundaries
* Architect stateful ans stateless to optimize scalability and reliability
* Implement service using 12-factor best practices
* Build loosely coupled services by implementing a well-designed REST architecture
* Design consistent, standard RESTFul services APIs

### Microservices

Make sure there is a good reason.
* Enable teams to work independently
* finer-grained scaling of services

To achieve independance on service, they should all have their own datastore
* allow you to select the best datastore solution for the service selected
* Datastore is a way to couple services together, which we want to avoid

Microservices, Pros:
* Easier to develop and maintain
* Reduced risk when deploying new versions
* Services scale independently to optimize use of infrastructure
* Faster to innovate and add new features
* Can use different languages and frameworks for different services
* Choose the runtime appropriate to each service

Microservices Cons:
* Increased complexity when communicating between services
* Increased latency across service boundaries
* Concerns about securing inter-service traffic
* Multiple deployments
* Need to ensure that you don't break clients as versions change
* Must maintain backward compatibility with clients as the microservices evolves

Decomposing Software into microservices (use DDD to achieve this)
* Decompose applications by features to minimize dependencies
* Organize services by architectural layer
* Isolate services that provide shared functionality (like authentication)

Stateful and stateless have different challenges
* Stateful are harder to scale, manage, upgrade...
* Stateless are easier to scale (add new instances), migrate new versions, administer
    * They got their state from the environment (like the request when API Rest Call)
    * But not possible to avoid stateless applications
    
* Avoid in-memory shared state, as:
    * It does not work well with the loadbalancer, who can send too much requests to the same server because of the session
        * Stocky sessions (session affinity in GCP)
    * scaling is not possible because the new service will not be in the same state as the others
* The recommended best practice would be using backend storage service, such as firestore, or CloudSQL
    * To avoid latency and for faster access, cached the data to your server by using the Cloud MemoryStore
    * Isolate the stateless and stateful services. This way, you can optimize most of your services exploitation, and keep a small part of your park harder to maintain.

### Microservices Best practices
12 factors app is a set of best practices for building web or software as a service applications

1. Codebase => Should be tracked (git)
    * One repo per application
    * Cloud source repository
2. Dependencies
    * Isolation => isolated by packaging them into a container
    * Declaration => must be in the codebase and store with the service (maven, pip)
    * Container registry works fine for that
3. Configuration => different environments
    * External to the code (don't put secrets, connection string in the code)
    * kept in environment variables for deployment flexibility
4. Backing services => Treat them as attached resources
    * Swap implementations easily
    * Databases, caches, queues, and other services are accessed via URLs
5. Build, release, run => Software deployment process should be broken into three distinct stages
    * Each state should result in an artifact's that uniquely identifiable.
    * Each build create a deployment package
    * Each release combines a runtime environment with the build
        * Releases are great for roadmaps, visible audit trail
    * The run is just when you run the app
6. Processes => Applications run as one or more stateless processes
    * If stateful is needed, use the best practice (backend storage + caching service)
7. Port binding => The application should be exposed using a Port number
    * The application bundles the webserver as part of the server, and do not require another server to run, like Apache
    * Uses GCE, GKE, GAE, GRun, Gfunction
8. Concurrency => Scale out by starting new processes, and scale back with load
9. Disposability => Applications should be written to be more reliable than the underlying software they run on
    * Handles temporary failures
    * Gracefully shutdown and restart quickly
10. Development production parity => Same env as dev/stage and production.
    * Use containers for this + IAC = it makes it easier
    * GCP tools to keep env consistent:
        * Cloud source repo, Cloud Storage, Cloud registry and Cloud Deployment Manager
11. Logs => provide the health of the application
    * Decouple the collection of processing and analysis of logs from the core logic
    * Logging should be standard output, and aggregated into a single source
    * Useful when apps are running on public clouds, because it eliminates the overhead of managing storage locations for logs
12. Admin processes => Usually mono processes, decoupled of the application
    * Automated and deployable, not manual
    * Cron jobs on Cloud Tasks on App engine, and Cloud Scheduler

### Activity : Decouple your application into microservices

PermanenceUI -> AuthService
            -> MemberReferentiel
            -> SaleService -> AccountService <- AccountantUI
SchoolUI -> AuthService
        -> SchoolService
        -> MemberReferential
        
### REST

* A good microservice is loosely coupled
* Provide a well defined contact to your client
    * Client should not need to know to many details of services they use
    * Don't break contract unless you are certain that no more client relies on it
    * Take rollback into account
    * Culture around contract is the most challenging organisational
* Services communicate via HTTPS using Text-based payload
    * Client makes GET, POST, PUT or DELETE request
    * Body of the request is formatted as JSON or XML
* Services should add functionality without breaking existing clients
    * Add, but don't remove, items from responses

"If microservices aren't loosely coupled, you will end up with a really complicated monolith"

* REST is REpresentational State Transfer
* REST is protocol independant, HTTP is the most used, but gRPC is also used.
    * The use cases can influenced the protocol choice, like if you are doing streaming
* Service endpoints supporting REST are called RESTFul
* Client and Server communicate with Request - Response processing

Restdul services communicates over the web using HTTP(S)
* Resources are identified by URI (or endpoints)
    * Responses return an immutable versions of the resource information
* HATEOAS : Hypermedia As The Engine Of Application State 
    * Allows a client to know what service with less knowledge of the server
    * The server handles the possible service access in the response
* REST applications provide consistent, uniform interfaces
    * Representation can have links to additional resources
* For immutable resources, consider using caching to improve performance and reduce costs

Resources and representations
* Resource is an abstract notion of information
* Representation is a copy of the resource information
    * Representation can be single items or a collection of items (batch APIs), because more efficient
* The representation of a resource is a copy of the resource information

Passing representations between service is done using standard text-based formats
* JSON is mostly used
* Can be HTML
* CSV
* XML

For external communication, JSON is the standard. For internal where performance is key, gRPC can be considered

### HTTP

HTTP requests composition:
* VERB (GET/PUT...) | URI (/myUri) | VERSION (HTTP/1.1)
* Request Headers (agent, accept..., content-type, content-length)
* Request body (optionnal, ued for PUT/POST requests)

* GET: retrieve data
* POST: create data
    * ID generated by the server and returned to the client
* PUT: Create or altering data
    * Entity ID must be known
    * PUT should be idempotent => requests made multiple times should always have the same result
* DELETE: Delete data

HTTP responses:
* HTTP Version | response code (2** = ok, 4** = client in error, 5** = Server in error)
* Response Header (content-type, length)
* Response Body (JSON, XML, HTML...)

Uniform Resource Identifiers
* Plural nouns for sets (collections): GET/pets
* Singular nouns for individual resources: GET/pet/1 (or /pets/1 when pets is also a collection)
* Strive for consistent naming
* Don't use verbs to identify a resource
* Include version information

/pets/{petId}

### API

Important to design consistent API for services
* Each google Cloud service exposes a REST API
   * Functions are in the form: service.collection.verb
   * Parameters are passed either in the URL or in the request body in JSON format
* For example, the compute engine APIs has:
    * A service endpoint at https://compute/googleapis.com
    * Collections include instances, instanceGroups, instanceTemplates...
    * Verbs include insert, list, get
* So, to see all your instances, make a GET request to:
    * https://compute.googleapis.com/compute/v1/projects/{project}/zones/{zone}/instances
    
OpenAPI is an industry standard for exposing APIs to client:
* Standard interface description format for REST APIs
    * Language agnostic
    * Open-source (based on Swagger)
* Allows tools and humans to understand how to use a service without needing its source code
* Is a yml file describing your service

```yaml
openapi: "3.0.0"
info:
    version: 1.0.0
    titile: Swagger petstore
    licence:
      name: MIT
servers:
    - url: http://petstore.swagger.io/v1
paths:
    /pets:
      get:
      summary: List of all pets
      operationId: listPets
      tags:
        - pets
...
```
=> A GET request at http://petstore.swagger.io/v1/pets will get us a list of all pets 

gRPC is a lightweight protocol for fast, binary communication between services or devices
* developed at Google
    * Supports many languages (Android, Java, C#, python...)
    * Easy to implement
* gRPC is supported by Google services
    * Global load balancer (HTTP/2)
    * Support both client and server streaming
    * Cloud Endpoints
    * Can expose gRPC services usgin an Envoy Proxy in GKE
    
Google provides 2 tools to managing APIs:
* Cloud endpoint:
    * API management gateway: develops, deploy and manage API on any Google Cloud Backend
    * Runs on Google Cloud
* Cloud Apigee:
    * Management platform built for enterprises with deployment options on Cloud, on-premises or hybrid
    * API gateway
    * Customizable portals, for on-boarding partners and developers
    * For any HTTP/S backend no matter where they are running (on premise or cloud)
* Both provides solutions like:
    * Authentication, monitoring, securing and also for OpenAPI and gRPC

### Activity: Design API for Cloud CMR

| Service name | Collections | Methods  |
|--------------|-------------|----------|
| Member Referential | members | list, get, update, delete, add |
| Sale Service | sales | list, open, close | 
| Sale Service | items | add, remove, update | 
| Catalog Service | items | list, get, update, delete, add |
| Accountant Service | transactions | list, get, export |
| Authentication Service | users | login, logout |
| School Service | schools | list, get, delete, update |
| School Service | teachers | list, create, update, delete |
| School Service | students | list, create, update, delete |
| Permanence UI | members | list, create, update, delete |
| Permanence UI | items | list, get |
| Permanence UI | sales | open, validate, cancel |

## DevOps Automation
DevOps is a key factor in achieving consistency, reliability and speed of deployment
* Automate service deployment using CI/CD pipelines
* Leverage Cloud Source Repositories for Source and version controls
* Automate builds with Cloud Build and build triggers
* Manage containers images with Container registry
* Investigate infrastructure with code using Cloud Deployment Manager and Terraform 

### Continuous Integration Pipelines

Developers check-in code -> Run unit tests (success only) -> Build deployment package (docker) -> deploy (save to container registry)
* Each microservices should have its own repository
* Extra step includes:
    * Code linting
    * quality analysis (SonarQube)
    * Integration tests
    * generating tests report
    * image scanning

google provides this components to build the integration pipeline.

* Cloud Source Repositories (like github)
    * Git repo
    * IAM to configure Access
    * Publish to pub/sub topic on 
        * Repo creation or deletion
        * Commit on repo
    * Enable debug in production, audit and logging (snapshot)
    * direct deployment to App engine
    * Auto sync with Cloud Source repositories automatically
* Cloud Builds execute build on cloud infrastructure
    * Can import source code from Cloud Storage, Cloud Source Repositories, GitHub or BitBucket
    * Produces images like Docker container or Java archives
    * Execute build as a serie of steps
    * Each step are run in a Docker container
        * Standard or custom step
    * Docker hosted-build service and is an alternative to Docker build
    * The CLI can be used to submit a build using gcloud
        * `gcloud build submit --tag gcr.io/your-project-id/image-name .`
            * `--tag`: the tag name of the image. Must use the *.gcr.io.* namespace.
            * ` . `: represents the location of the source to build
* Cloud triggers: watches changes in the repo and starts the build
    * Build a container whenever code is pushed
    * Whenever a change is made to the code source
    * Set on commit made on a branch, or tag, or a regex of a branch or tag
    * either in dockerfile or cloudBuild file
    * Source can be selected:
        * GitHub, Cloud Repositories, BitBucket
* Container Registry (like DockerHub)
    * A registry for your images
    * Images built with Cloud Build are automatically saved in Cloud Registry
    * Can use the `docker push/pull gcr.io/project-id/image-name:tag` command
* Binary authentication
    * Enforce deployments of only trusted containers into GKE
    * Enable binary authorization on the GKE clusters
    * Based on kritis specification
    * a policy is required to sign the images
        * when the image is build by Cloud Build and attestor verifies that it was from a trusted repository
    * As part of the build, do a vulnerabilities scan on containers
        * When new image is uploaded
        * Scanner publishes to pub/sub
        * Kritis signer listens to pub/sub notifications from Container Registry vulnerability
        * Then attests the image is secured if it passed the vulnerability scan
        
### Infrastructure as a Code

| On premises | Cloud |
|-------------|-------|
| Buy machines | Rent machines |
| Keep machines running for years | Turn machine off as soon as possible |
| Prefer fewer big machines | Prefer lots of small machines |
| Machines are capitable expenditures | Machines are monthly expenses |

The key for cloud computing: all infrastructure needs to be disposable.
* Don't fix broken machines
* Don't install patches
* Don't upgrade machines
* If you need to fix a machine, delete it a re-create a new one
* This leads to problem when recreating new environment later

IAC:
* to make infrastructure disposable automate everything with code :
    * Can Automate using scripts (deploying 100 machine is the same effort)
    * Can use declarative tools to define infrastructure
    * Create an ephemeral test environment mirroring the Prod environment
    
In essence, IaC:
* quick provisioning and removing infra
* On-demand provisioning is very powerful and can be integrated into an integration pipeline
    * smooth-path to continuous deployment
    * deployment complexitiy is managed in the code
    * Provides the flexibility to change infra as requirements change, and all the changes are in one place
* Build an infra when needed
* Destroy the infrastructure when not in use
* Create identical infra for dev, test and prod
* Can be part of CI/CD pipelines
* Templates are the building blocks for disaster recovery procedures
* Manage resource dependencies and complexity

IaC with Google is done through the Cloud Deployment Manager:
* Deployment manager language
* Terraform
* Chef
* Puppet

* Configuration file in yml
* Template enforce reusable components.

It seems like Terraform and Deployment Manager are both recommended by Google. But Terraform is also usable on private cloud.
It is more popular, so I think Terraform is the best choice when learning IaC with GCP (more valuable later on)

Both can do the same things (code is a side effect). Terraform automatically comes with the Cloud Shell.


### Labs: DevOps pipeline

My review:
* We first create an empty repo on cloud Repositories
    * We could have one on gitHub
* the `gcloud source repos clone REPO_NAME` command allows to get the repository
* Create a Dockerfile to build a Docker Image for your application
* Build the DockerFile using Cloud Build
    * `cloud build submit --tag ... .` build the Docker image and pushes it to the Google Container Registry
    * It is the same as using `docker build && docker push`
* Create a build Trigger (cloud Build > Triggers) to automatically start a Cloud Build actions
    * To Test it, use `Run Trigger` on the GCP Console
* This is only Continuous Integration, not Continuous Deployment, as we had to manually deploy the app on the next

## Choosing Storage Solutions

* Choose the appropriate Google Cloud data storage service based on use case, durability, availability, scalability and cost
* Store binary data with Cloud Storage
* Store relational data using Clous SQL and Spanner
* Store NoSQL data using Firestore and Cloud Big Table
* Cache data for fast access using Memory Store
* Aggregate data for queries and repors using BigQuery as a data warehouse

### Key Storage characteristics

* Relational: Cloud SQL, Spanner
* NoSQL: Firestore, BigTable
* Object: Cloud storage
* Warehouse: BigQuery
* In memory: Memorystore

Make a decision on the Data storage has to take into accounts:
* The Data
* scale
* Availability
* Durability
* Location
* Custom requirements

Choose a storage given the Availability SLA (uptime) and the constraints you have:
* Cloud Storage
    * multi-region bucket: >= 99.95%
    * Regional bucket : 99.9%
    * coldline : 99.0%
* Spanner
    * Multi-region: 99.999
    * single region: 99.99
* Firestore
    * Multi-region: 99.999
    * Single-region: 99.99

To determine availability: Total of minutes in a month - number of minutes of downtime period suffered from all downtime period in a month / Total number minutes of a month

Durability: the odds of losing the data
* Google ensure the data is durable
* You have to do the backups of your data to avoid loss
* => It is a shared responsabilities

* Cloud storage : 11' 9 after 99... |
    * You:  should use the versioning, to turn it on
    * And add a policy management to avoid having too much data and automatically archiving old data
* Disks: snapshots
    * You: Schedule snapshots jobs
* Cloud SQL: Automated machine backups, failover server (optional)
    * You: Run SQL database backups
* Spanner | Firestore: automatic replication
    * You: Run export jobs to export data to Cloud Storage
    
The amount of Data and numbers of read and write is important when selecting Storage Solution
* Horizontal scalability (add nodes)
    * BigTable, Spanner
* Vertical scalability (machine bigger)
    * Cloud SQL, MemoryStore
* Auto scale with no limits
    * Cloud Storage, BigQuery, Firestore
    
Strong consistency is also to consider (ensure everybody get the latest copy of the data on reads)
* Cloud Storage
* Cloud SQL
* Spanner
* Firestore

Eventual consistency update one copy of the data and the rest asynchronously, But they can handle bigger writes
* BigTable
* Memorystore replicas

Calculating the cost (Price calculator)
* Firestore: less expensive per GB storage, but cost for reads/writes operations
* Storage: not expensive (and cost changes with Storage class)
* BigQuery: pay for the query, but really cost effective for massive dataset
* BigTable and Spanner are expensive, but handling big Dataset

Constraints: DataType / ReadsWrites / Size

### Choosing Google Cloud Storage and Data solutions

Relational (fixed schema):
* Cloud SQL:
    * Use cases: E-commerce, Web Application
    * Scales up to 30TB
    * PostgreSQL, MySQL, SQL Server
    * regional or multi-regional (depends on your availability criteria)
* Cloud Spanner:
    * scalable RDMBS
    * Use cases: User metadata, Ad/Fin/MarTech
    * Regional or multi-regional

NoSQL (schemaless):
* FireStore:
    * Hierarchical, mobile, web
    * User Profiles, GameState
    * Document database (document size < 1Mb)
* BigTable:
    * Scales infinitly
    * heavy read/writes events, IoT, digital Ad streams

Binary: 
* Cloud Storage:
    * Images, media serving, backups

DataWarehouse:
* BigQuery:
    * analytics and BI dashboard

Memory:
* MemoryStore
    * Caching for mobile/web app
    * fast access data to microservices architecture

In case of data migration into the Cloud, you might consider the dataset size and speed transfer. 
(This can also helps you choose between connection type to Google infrastructure)
     (1Mbps to 100Gpbs)
1GB: 3 hrs to 0.1s
1TB: 12 days to 11secs
1PB: 340 years to 30 hrs
100Pb: 34048 years to 124 days

Online and Offline data transfer option:
* Import online data to Cloud storage:
    * Amazon S3
    * HTTP/HTTPS Location
    * Transfer data between Cloud Storage buckets
* Option to make your transfer easier: Scheduled jobs
    * One time or recurring, import at a scheduled time of day
    * Options to delete objects not in source after transfer
    * Filter on file name, creation date

* Storage Transfer service on-prem
    * Install on premises agent on your servers
    * Agent runs in a Docker container
    * Setup a connection to Google Cloud
    * Requires a minimum of 300Mbps bandwidth
* Scales to billions of files and 100s of 1TB
* Secure
* Automatic retires
* Logged
* Easy to monitor via Cloud Console

The last one, if previous solutions take too long to upload is Transfer Appliance:
* Rackable device up to 1PV shipped to Google
* Use Transfer Appliance if uploading your data would take too long
* Secure:
    * You control the encryption key
    * Google securely erases the appliance after use
* I insist: it is a hardware, that you have to ship after to Google, and they import the Data in your project
* Data is encrypted to AES 256

BigQuery transfer service, to import data to your analytics Query:
* Saas applications to BigQuery on a scheduled managed basis

## Google Cloud and Hybrid Network Architecture

### Overview
* Design VPc networks to optimize for cost, security and performance
* Configure global and regional load balancers to provide access to services
* Leverage Cloud CDN to provide lower latency and decrease network egress
* Evaluate network architecture using the Network Intelligence Center
* Connect networks using peering, VPNs and Cloud Interconnect

### Designing Google Cloud Networks
Meet criteria such as user location, scalability, fault tolerance and latency

A compute engine instance can be connected to multiple networks, because it can have multiple network interfaces.
The number of network interfaces available depends on the number of VCP used by the VM.

Shared VPC: connect multiple project and they communicate securely
* Central configuration over network
    * Network admins configure subnets, firewall rules, routes, etc.
    * Remove network admin rights from developer
    * Developers focus on machine creation and configuration in the shared network
    * Disable the creation of the default network using an organization policy
* Create VPC in host project

### Designing Google Cloud load balancers

* Default: request is routes to the closest engines available to the users (if it has enough resources)
* Enable HTTPS (with your own SSL certificate, or by using one provided by Google)
* to reduce latency, enable Cloud CDN
    * can be enabled when configuring the HTTP global load balaner
    * Caches static content worldwide using Google Cloud Edge-cahcing locations
    * Cache static data from webservers in Compute engine instances, GKE pods or cloud Storage location


* Internal vs external Load balancer
* Regional or multi-regional (global)

* HTTP/S Load balancer (internet and internal, regional and global)
* TCP/SSL Load balancing (internet and internal, regional and global)
* TCP/SSL Proxy (internal proxy)
* UDP Load balancing (only regional, internet and internal load balancing)

* Network intelligence center
    * Tool that helps visualize the VPC network topology
        * External clients, LoadBalancer, region routed
    * Test network connectivity
        * Source and destination
        * source and destination inside VPc networks
        * VPC network to and from the Internet
        * VPC network to and from your on-premises network

### Connecting networks

Vpc networks => connection via VPC Peering
* Can be the same or different organizations
* Subnet ranges do not overlap (requirement to establish the connection)
* Network admins for each VPC must approve the peering requests
* they both have their own firewall rules

Use CloudVPN to connect a Cloud network with an on-premise network or another cloud

Classic Cloud VPN:
* IPSec VPN tunnel
* 99.9% monthly uptime SLA
* Traffic is encrypted via one hand and decrypted by the other hand
* Configure static/dynamic route like BGP
* Low volume of connection, 3Gbps

HA Cloud VPN:
* 99.99% monthly uptime SLA
* 2 IP addresses and 2 VPN Gateways are required on-premises
* Each gateway supports multiple VPN tunnels
* A HA VPN gatway connects to 2 peer devices
    * each peer devices has 1 public IP address and 1 interface
    * Uses 2 tunnels, one per device
        * Provides failure and upgrade individually
        
Static routes can be configured. If you want dynamic route, you need to configure Cloud Router:
* changed route without changing tunnel configuration

If you need more bandwidth, use Cloud Interconnect to have a dedicated high speed connection
* Dedicated interconnect: if close to one of the google co-location facility
    * 10Gbps to 100gbps circuits
    * maximum of 200Gbps
* Partner interconnect: Use a service provider to connect to Google services
    * 
    
    
## Deploying Applications to Google Cloud

### Overview 
* Specific OS and machine requirements
    * Yes: Compute engine
    * No: 
        * Using Containers
            * Yes: 
                * Do you want to manage your own kubernetes cluster ?
                    * Yes: GKE
                    * NO: Cloud Run
            * No:
                * Is your service event-driven
                    * Yes: Cloud Functions
                    * No: App engine

In this module, we will cover how to deploy app on google

### Google IAAS  
Compute engine is the IAAS of Google. Consider it when:
* You need complete control over your OS
* You have an application not containerized
* Your application is a self hosted database

Instance groups:
* create VMs from templates
    * Boot disk image, machine type labels, 
* Use a startup script from a GIT repo
* Instance group manager creates the machines
* Set up autoscaling to organize cost and meet varying user workloads
    * Add a health check
    * Use multiple zones for high availability
    
Recommendation: Use one or more instance groups as the backend for load balancers.
* If you need instance groups in multiple regions, use a global HTTP balancer. 
* If you have static content, enables Cloud CDN

### Google Cloud Deployment Solutions

GKE: Manages a Kubernetes cluster on Compute Engine instances.
* Cluster is composed of:
    * Master (managing autoscaling and stuff ?)
    * Nodes: The compute engine instances
    * Pods: smallest deployable units of your application (docker container(s))
        * Pods run on Compute engine instances (Node)
        
Cloud Run:
* Runs a container on a kubernetes cluster
* But we don't have to manage the servers
* The image must be stored on Cloud Registry
* Apps must be stateless
* Use Anthos Cluster if you need more control over services because it allows:
    * To access VPC network
    * To tune the size of compute instances
    * To run services in all GKE regions

App engine:
* Fully managed serverless application platform
* One app engine per project:
    * A project has multiple services (and one named 0)
        * Services have versions
            * Versions run on instance

Cloud Functions:
* Loosely coupled event driven micro-services
* Processing events that occurs in Google Cloud
* No pay when no requests are made
* Pay at execution time every 100ms
* Auto scalable

Example: Text on image translations
* An image is uploaded to a Cloud Storage Bucket
* A cloud function is triggered when such an event occured
    * the cloud Function calls the Cloud Vision API and get the text on the image
* The result is sent to a Translation Topic Pub/Sub
* Another Cloud Function is triggered when a message is posted on a Pub/Sub Topic
    * this function calls the Cloud Translation API and get the translated text in multiple languages
* The result is published to a FileWriter topic Pub/Sub
* A last Cloud Function writes the result to a file in Cloud Storage

## Designing Reliable Systems

### Module overview
* Design services to meet requirements for availability, durability and scalability
* Implement fault-tolerant systems by avoiding Single Point Of Failure (SPOF), correlated failures and cascading failures
* Avoid overload failures by leveraging the circuit breaker and truncated exponential backoff design pattern
* Design resilient data storage with lazy deletion
* Design for normal operational state, degraded operational state and failure scenarios
* Analyse disaster scenarios and plan, implement and test/simulate for disaster recovery


### Key Performance Metrics
When designing for reliability, consider:
* Availability: The percent of time a system is running and able to process requests
    * Achieved with fault tolerance
    * Create backup systems
    * Use health checks
    * Use white box metrics to count real traffic success and failure
* Durability: The odds of losing data because of a hardware or system failure
    * Achieved by replicating data in multiple zones
    * Do regular backups
    * Practice restoring from backups
* Scalability: The ability of a system to continue to work as user load and data grow
    * Monitor usage
    * Use capacity auto-scaling to add and remove servers in response to changes in load
        * Metrics can be CPU, RPS, or custom like number of users on a game

### Designing for reliability

Avoid SPOF: a spare spare 
* you should deploy 2 extra instances, or N+2 to handle both failures and upgrades
* Define your unit of deployment
* Ideally they should be in different zones to mitigate the zonal failure
* Make sure that each unit can handle an extra load
* Don't make any single unit too large, it is harder and more expensive to backup
* Try to make units interchangeable stateless clones
    * Easier and faster to exchange

Consider a scenario where you 3VMs deployed to achieve N+2
* If one is being upgraded, and the other fails, you'll have less capacity to handle the loads, putting everything on the last one remaining
* Consider this when designing your system

Correlated failures: what are they ?
* Simple level: If a single machine fails: all requests served by that machine fail
* Hardware level: If a top-of-rack switch fails, entire rack fails
* cloud level: If a zone or region is lost, all the resources in it fail
* Software level: Servers on the same software run into the same issue
* If a global configuration system fails, and multiple systems depend on it, they potentially fail too

The group of related items that could fail together is a failure domain

How to avoid them ? Decouple servers and use microservices distributed among multilple failure domains 
* Divide business logic into microservices based on failure domains
* Deploy to multiple zones and/or regions
* Finer level of granularity: Split responsability into components and spread over multiple processes
    * A failure in one component will not affect other components
    * If responsability are in one components, a failure in one responsability has a high likelihhod of causing all responsabilities to fail
* Design independent, loosely coupled but collaborating services    
    * A failure in one service may not cause failure in another service
    * It may cause the collaborating service to have a reduced capacity or not be able to fully process its workflows
        * But it remains in control, and does not fail
    
Cascading failures: when one system fails, this causes an overload to the other system, such as a queue message because of the failing backend service
* Server A and B split the charges, they get 600 RPS each, and can both handle 1000 RPS
* Server B fails, causes server A to handle the 1200 RPS. A is now overloaded, and could fail

How to avoid them ? 
* Use health checks in Compute Engine or readiness and liveness probes in kubernetes to detect and then repair unhealthy instances
* Ensure that new server instances start fast and ideally don't rely on other backends/systems to startup
* Design your system to handle the loads: have one more machine (N+2) in case, but be careful of the overall costs

Queries of deaths, where a request made to a server causes a failure in the service. Very difficult to diagnoze
* Problem: Business logic error shows up as overconsumption of resources, and the services overloads
* Solution: 
    * Monitor query performance.
        * Latency, resource utilization, error rates
    * Ensure that notifications of these issues get back to the developers

Plan against positive feedback cycle overload failure
* Problem: You try to make the system more reliable by adding retries, and instead you create the potential for overload
* Solution:
    * Prevent overload by carefully considering overloaded conditions whenever you are trying to improve reliability with feedback mechanisms to invoke retries

2 strategies to address this:
* Truncated Exponential backoff patterns = give time to a service to get ready again
    * Continue to retry, but wait a little longer between each attempts
    * Set a maximum length and a maximum number of requests
    * Eventually, give up
* Example:
    * Request fails: wait 1 second + random ms number
    * Request fails: wait 2 seconds + random ms number
    * Request fails: wait 4 seconds + random ms number
    * Continue until you reach the limit

* Circuit breaker pattern: protect from too many retries
    * Plan for degraded state operations
    * If a service is down and all its clients are retrying, the increasing number of requests can make matters worse
        * Protect the service behind a proxy that monitors health (the circuit breaker)
        * If the service is not healthy, don't forward requests to it
        * Once it is up again, start sending the load, in a controlled manner
    * If using GKE, leverage Istio to automatically implement circuit breaker
    
Lazy deletion to reliably recover when users delete data by mistake
* A deletion pipelines is initiated:
    * when the user deletes the data, it enters in a "trash",
        * The data could still be recover by the user, maybe by a custom UI...
    * After a certain times, 30 days for instance, the data is moved to a soft-deletion place
        * Only admin could restore the data, that is no longer visible to the user
    * After another period of time, like 15 days, the data is hardly deleted from the system
        * The only way to recover would be to have a backup or archives
    
### Activity: Design Reliable scalable applications
In my case, my application is composed of multiple UIs, but only facing users in Europe. The region europe-west1 is a perfect choice for low latency.
The application is composed of small App engine services. They will be run by App engine the Europe-west1 region.
I do not have to worry about availability, it is provided by App Engine. Some accounting data will be stored in a Storage Bucket.
These data are important, and will be versioned and store in a multi-regio, storage bucket (if not too expensive).
The data solution I'll be using will be Data storage solution managed by Google. The default SLA provided by the Firestore and Cloud SQL single region are enough for me.
To ensure durability, backup and export will be frequently executed, to recover from a disaster.

Things to consider: to reduce cost, I want my app engine application to communicate through internal network, not facing the internet. I need to to see how this works.  

### Disaster planning

High availability can be achieved by deploying to multiple zones in a region:
* Deploy multiple servers
* Orchestrate servers with a regional managed instance group
* Create a failover database in another zone or use a distributed database like Firestore or Spanner, those provide high availability by default

* Choose between single, multiple zones or regional configuration when creating the instance group instance.
* It is the same for GKE
    * Kubernetes cluster consists of a collection of node pods
    * Selecting regional location type replicates node pools in multiple zones in the region specified

Create a health check to enable auto-healing when creating instance groups
* Create a test endpoints in your service
* Test endpoint needs to verify that the service is up and also that it can communicate with dependent backend database and services
* If health check fails, the instance group will create a new server and delete the broken one
* Load balancers also use health checks to ensure that they send requests only to healthy instances

Cloud Storage:
* Multi-region: 99.95% availability. 0.026$/Gb
* single-region: 99.9% availability. 0.020$/Gb

Cloud SQL:
* Create a failover replicas
* Automatic switches when the master fails

Firestore and spanner:
* Provide automatic High availability
* Firestore/Spanner single region: 99.99% -> data replicated across multiple zones
* Firestore/Spanner multiple region: 99.999% -> data replicated across multiple regions
    => 6 minutes of downtime per year... But there is some down time

Deploying for High availability increases costs.
* To help design and choose, a good tool is this table:

| Deployment | Estimate Cost | Availability % | Cost of being down |
|------------|---------------|----------------|--------------------|
| Single zone | | | |
| Multiple zones in a region | | | |
| Multiple regions | | | | 

Disaster recoveries strategy

Cold standby: Likely to be the cheapest, but gives the longest down time
* Keep snapshots and backups of your service in a multi-region storage
    * Multi region is important, because if you loose a zone, and your backup is in the same zone, then you loose your backups too...
* If main region fails, spin up servers in backup regions
* Document and test recovery procedure regularly

Hot standby: instance groups exist in multiple regions, and traffic is router with a global HTTP load balancer
* Mirror Instance groups in another region
* Use a global load balancer
* Store unstructured data in multi-region buckets
* For structured data, use multi-region database such as Spanner or Firestore

Any disaster plan should come up with 2 metrics: Recovery point objective and the recovery time objective
* The recovery point objective is the amount of data that would be acceptable to lose
* The recovery time objective is how long it can take to be back up and running ?
 
When disaster planning, brainstorm scenarios that might cause data loss and/or service failure
* What could happen that would cause a failure
* What is the Recovery Point Objective ?
* What is the Recovery Time Objective ?

Draw a table with columns:
* Service (Product rating service, Orders Service)
* Scenario (Programmer deleted all ratings accidentally, Database crashed)
* Recovery Point Objective (24 hours, 0)
* Recovety Time Objective (1 hour, 1 minute)
* Priority (Mod, High)

Then create a plan based on the disaster scenario you define.
* For each scenario, devise a strategy based on the risk and recovery point and time objectives
* Don't just document it. Communicate it over all parties
* Test and validate the procedure for recovering from failures regurlaly
* Ideally, recovery becomes a streamlined process, part of daily operations

Outcomes:

| Resource | Backup Strategy | Backup Location | Recovery Procedure |
|----------|-----------------|------------------|-------------------|
| Ratings MySQL databases | Daily automated backups | Multi regional Cloud storage bucket | Run Restore scripts
| Orders Spanner Database | Multi-regional deployment | us-east1 backup region | Snapshot and backup at regular intervals, outside the serving infrastructure; e.g Cloud Storage |

Prepare a team to disaster by using drills:
* Planning
    * What can go wrong with your system ?
    * What are your plans to address each scenario ?
    * Document the plans
* Practice periodically
    * Can be in production or a test environment as appropriate
    * Assess the risks carefully
    * Balance against the risk of not knowing your system's weaknesses

### Activity: Disaster planning
Questions to ask:
* You can alwasy imagine that a programmer will delete a table... But in the case of very sensitive data, like orders, can we really protect against this ?
    * I mean, we will never be able to have a 0 minute recovery point objective with backups
        * And will a failover, or a replicate also deletes the table like the programme did ? In this case, there is nothing we can do...
        
I still need to dig a little bit this part
 
Useful resources:
* https://cloud.google.com/solutions/dr-scenarios-planning-guide

## Security

Security should always come first.

* Design secure systems using best practices like SoC, Least privilege, and perform regular audits
* Leveraging Google's Security Command Center to help identify vulnerabilities
* Simplify cloud governance using organization policies and folders
* Authenticate and authorize users with IAM roles, Identity-Aware Proxy and Identity platform
* Manage the access and authroization of resources by machines and processes using service accounts
* Secure network with private IPs, firewalls, and Google Cloud private access
* Mitigate DDoS attacks by leveraging Cloud DNS and Google Cloud Armor

### Security concepts

* The security is a shared concerns between Google and you. 
* Some actions are managed and secured by google, some are your responsabilities.
* We need to have a strong transparency to make sure the security of your application is strong and complete
* Google provides the tools necessary to properly monitor our services

Security is implemented in layers:
* Hardware
* Boot
* OS + IPC
* Storage
* Application
* Deployment
* Operations
* Usage

* To improve security, you can integrate third-party tools
* There is also tools for auditing and monitoring resources and networks

Principe of least privilege:
* grant to user the minimal access to perform their duty
*  This also applies to machine (service account)
* Use IAM to enforce this principle
* Identify users with their login
* Identify machines and code using service accounts
* Assign IAM roles to users and service accounts to restrict what they can do

Separation of duties:
* Prevention conflict of interest
* Detection of control failures

It means:
* No one can change or delete data without being detected
* No one can steal sensitive data
* No one is in charge of designing, implementing and reporting on sensitive systems
* For example: people who write the code shouldn't be able to deploy it. People on deploy the code shouldn't be able to change it

Advices:
* Use multiple projects to separate duties
* Different people can be given different rights in different projects
* Use folders to help organize projects

Vital to audit Cloud Logs services to discover attacks. Those logs keep track of:
* Admin logs
* Data access logs
* VPC Flow logs
* Firewall logs
* System logs

Google meets many third-party and government compliance WorldWide.
That doesn't mean our application is certified. We are responsible for what we build.

Security Command Center, provides access to organizational and projects security configuration.
* Provide a dashboard that reports health analysis, threat detections, anormaly detection and a summary report
* Once a threat is detected, a set of actionable recommendations is provided

### Securing People

* When granting people access to your projects, you should add them as members as assign them roles.
* Create groups to easily manage roles to members, as the roles applied to the members are the roles of group
* Roles are a list of permissions.
* Use console to see the list

Use Organization policies and folders to simplify securing environments and managins resources.
* Roles should be granted to groups, not individual => Simplifies the management
* Groups can be more granular that job roles
* Use multiple groups for better control (such as view only)

Roles:
* Prefer pre-defined roles over custom-roles
    * Easier to maintain
* Grant roles at the smallest scope needed (least privilege)
* Limit use os "owner" and "editor" roles
* Consider hierarchy inheritance when assigning roles
    * What has been given on policy hierarchy can't be removed

Cloud Identity Aware Proxy (IAP):
* Limit access to application hosted on App Engine (standard and flexible env), Compute engines and GKE
* Works with web application deployed behind an HTTP/S load balancer
* Forces the user to log in
* Admins control who can access to app
* Allows employees to securely access web app without using a VPN

Identity Platform
* A platform to manage identity of the customers/users of your applications
* Provides sign-up and sign-in to end users
* Support a range of protocol: SAML, OpenID, e-mail and password, phone, social and Apple

### Securing machine access

Service account :
* Create a service account and grant it one or more roles
* Can assign that service account to VMs or GKE node pool
* those machines run with only the rights granted by the roles

When creating the service account, we are given the right to download the private key (if you need to authenticate as the service account)
* Make sure you keep it safe
* The key is used for authentication
* Key is downloaded as JSON

Can use service account key to configure the CLI
* Allow you to grant controlled Google Cloud access to developers without giving them access to the Cloud console
* Alos useful for automation when configuring VMs to run CI/CD pipelines
* Use `gcloud auth activate-service-account --key-file=<PATH_TO_KEY_FILE>` 

### Network security

Remove external IPs to prevent access to machines outside their networks, whenever possible
* If you need access, for instance updates or patches to be applies: use a bastion host to provide access to private machines
* Can also SSH into internal machines using IAP from the console and CLI
* Use Cloud NAT to provide egress to the internet from internal machines

=> All internet traffic should terminate at a load balancer, third-party firewall (proxy or WAF), API gateway, or IAP. 
That way, internal services can't be launched and get public IP addresses

Private acces allows access to Google Cloud services using an internal address
* Enabled when creating subnets (command or console)
    * `gcloud compute networks subnets update subnet-b --enable-private-ip-google-access`
* Allows access to Google Cloud services from VMs that only have internal IPs
    * For example, a machine with only an internal IP would be able to reach a Cloud Storage Bucket using its internal IP addresses

Always configure firewall rules to allow access to VMs
* By default, ingress on all ports are denied, and all egress is allowed
* Add firewall rules to control which clients have access to which VMs on which ports
* Application level security is your responsability
* Firewall rules are before the Load balancer

To manage API, use Cloud EndPoints:
* API management gateway that helps to develop, deploy and manage APIs on any Google Cloud backend
* Protect and monitor your public APIs
* Control who has access to your API
* Validate every call with JSON Web Tokens and Google API keys
* Integrates with Identity Platform

Restrict access to your services to TLS only (HTTPS)
* All Google Cloud services endpoints use HTTPS
* It's up to you to configure your service endpoints
* In the load balancer setup, only create a secure frontend
    * Provide your certificate, or one managed by Google

Levarage google Cloud network services for DDoS protection
* Global load balancers detects attacks and drop them
    * Level 3 and 4 traffic
* Enabling the CDN will protect backend resources
    * As the attacker will hit the cache, and not your resources

Use Cloud Armor to create network security policies
* Can allow or deny access to your Google Cloud resources using IP addresses or ranges
* Create whitelists to allow known addresses
* Create blacklists to block known attackers
    * Configure the response status to send back
* Supports layer 7 application rules
    * Predefined rules for preventing common attacks like SQL injection and cross-site scripting
    * Flexible rules language allows you to allow or deny traffic using requests headers, geographic location, ip addresses, cookies..
    * expressions can be logically combined using && and || operator 
    * Example
```
inIpRange(origin.ip, '9.9.9.0/24')
request.headers['cookie'].contains('80=TOTO')
origin.region_code == 'AU'
inIpRange(origin.ip, '1.2.3.4/32') && request.headers['user-agent'].contains('WordPress')
evaluatePreconfigureExpr('xss-canary')
```

### Encryption

Google Cloud provides server-side encryption of data at rest by default
* Data Encryption Key (DEK) uses AES-256 symmetric key
* Keys are encrypted by Key Encryption Keys (KEK)
    * this way, the DEK can be stored local for fast data decryption
* Google controls master keys in Cloud KMS
* Keys are automatically periodically rotated
* On-the-fly decryption by authorized user access with no visible performance impact

For compliance, you may need to manage your own key
* Customer-managed encryption keys (CMEK) are created in cloud using Cloud Management Key Service (KMS)
* You create the keys and specify the rotation frequency (default 90 days)
* You can then select your keys when creating storage resources like bucket and disks

Customer Supplied Encryption Keys encryption keys are created in your environment and provided to Google Cloud
* Use your own keys with Google Cloud Services
* CSEK are supplied by calling the application per-API call
* Only cached in RAM by google
* They decrypt a single payload (or column) or block of returned data
* Supported by Compute engine (persistent disks) and Cloud storage

The Data Loss Prevention API can be used to protect sensitive data by finding it and redacting it
* Scans data in Cloud Storage, BigQuery or Datastore
* Detects many different types of sensitive data:
    * emails
    * Credit card
    * Tax ID
* You can add your own information types
* Can delete, mask, tokenize, secure hasing, bucketing, format preserving encryption or just identify the location of the sensitive data

### Design activity: Security

## Maintenance and monitoring

* Manage new service versions using rolling updates, blue/green deployments, and canary releases
* Forecast, monitor and optimize service cost using the Google cloud pricing calculator and billing reports, and by analyzing billing data
* Observe whether your services are meeting their SLOs using Cloud Monitoring and Dashboards
* Use uptime checks to determine service availability
* Respond to service outages using Cloud Monitoring alerts

### Managing versions

In a microservices architecture, be careful not to break clients when services are updated
* A key benefit to microservice architecture is to be able to deploy services independently
* Ensure backward compatibility for all your clients
* Include version in URI
    * If you deploy a breaking change, you need to change the version
* Need to deploy new versions with zero-downtime
* Need to effectively test versions prior to going live

Rolling updates allow you to deploy new versions with no downtime
* Typically, you have multiple instances of a service behind a load balancer
* Update each instance one at a time
* Rolling updates 
    * work when it is ok to have 2 different versions running simultaneously during the update
    * Are a feature of instance groups, just change the instance template
    * Are the default in kubernetes, just change the Docker image
    * Are completly automated with AppEngine

Use a Blue/green deployment when you don't want multiple versions of a service running simultaneously
* The blue deployment is the current version
* Create a new environement (the green)
* Once the green deployment is tested, migrate client requests to it
* If failures occur, switch it back

How to do so ?
* In compute engine, use DNS switch to migrate requests from one load balancer to another
* In kubernetes, configure your service to route to the new pods using labels
    * Simple configuration change
* In app Engine, use the Traffic splitting feature

Canary releases can be used prior to a rolling update to reduce the risk
* The current versions continues to run
* Deploy an instance of the new version and give it a portion of the requests
* Monitor for errors
* The same approach as Blue/Green, but smoother
How to do so ?
* In compute engine, create a new instance group and add it as a backend in your Loadbalancer
* In kubernetes, create a pod with the same labels as the existing pods. the service will automatically route a portion of requests to it
* In app engine, use the Traffic splitting feature, and split traffic like 20-80, or 50-50...

### Cost planning

Capacity planning is a continuous, iterative cycle
* Forecast (estimate capacity needed, monitor, repeat)
* Allocate (determine resources required to meet forecastes capacity)
* Approve (Cost estimation versus risks and rewards)
* Deploy (Monitor to see how accurate your forecasts were)
* And do it again, do a new forecast for new project, with knowledge you had in the loop

Optimize cost of compute:
* Start with smalls, and increase with tests if needed
* Consider more small machines with auto scaling
* Consider committed used discounts
* Consider at least some preemptible VMs, when your algorithm can:
    * 80% discount
    * Use auto healing to recreate VMs when they are preempted
* Google Cloud rightsizing recommendations will alert you when VMs are underutilized

Optimizing disk cost
* Don't overallocate disk space
* Also, Determine what performance characteristics your application require:
    * I/O pattern: small reads and writes or large reads and writes
    * Configure your instances to optimize storage performance
* Depending on I/O requirements, consider standard over SSD disks
* 10Gb: 0.4$ standard / 1.70$ SSD
* 1Tb: 40$ standard / 170$ SSD
* 16Tb: 665.36$ standard / 5570.56$ SSD

To optimize network costs, keep machines close to your data
* Egress in the same zone is free
* Egress to a different Google cloud server using internal or external IP address within the same region is free
    * Except for some services such as MemoryStore
* Egress between zone in the same region is charged
* All internet egress is charged

When using App Engine, it is using Internet egress to talk from one machine to another, therefor, it is charged

GKE usage metering can prevent over-provisioning Kubernetes clusters
* Compare requested resources with consumed resources
* Data are gathered, and can be analyzed using BigQuery, or Data Studio dashboard

Compare the costs of different storage alternatives before deciding which one to use
* Choose a storage service that meets your capacity requirements at a reasonable cost:
    * Storing 10Gb in firestore is free (under the free access tier)
    * Storing 10Gb in Cloud BigTable would be around 1400$/month
        * Because you still need a high number of nodes

Consider alternative services to save cost rather than allocating more resources
* CDN: Cache
* Caching: MemoryStore
* Messaging with Pub/Sub to decouple communicating services
* Queueing
* etc...

For instance, don't create a datastore necessarily to share data between services: You can use Pub/sub. Could save some storage cost

Use the Google Cloud Pricing Calculator to estimate costs
* Based your cost estimates on your forecasting and capacity planning
* Compare the costs of different compute and storage services

To monitor the cost, use the Billing reports
* Provide a detailed cost breakdown
* the sizing recommendation for compute engine will also be in this report

For advanced cost analysis, export billing data to BigQuery
* Observe that the majority of your clients requests come from another continent, which increase the bill
    * Relocate your services, use CDN...

Visualize spends with Google Data Studio:
* Daily and monthly view
* Can also be drilled down for greater insights
* Easy to read, share and customizable

Set budgets and alerts to keep your team aware of how much they are spending

### Monitoring dashboards

To monitor SLO and SLAs:
* Monitoring, logging, trace, debbuger, error reporter and profiler

Monitor the things you pay for:
* CPU
* Storage capacity
* Reads and writes
* Network egress
* Etc.
* Helps determine the trends, bottlenecks and potential cost savings

Monitor your SLIs to determine whether you are meeting your SLOs

Create uptime checks to monitor availability and latency

Latency is actually one of the four golden rules called out in Google's Site Reliability Engineering, or SRE book.

