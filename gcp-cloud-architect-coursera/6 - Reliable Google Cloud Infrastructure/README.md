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
        * Durability - 
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
* Build loosely coupled sercices by implementing a well-designed REST architecture
* Design consistent, standard RESTFul services APIs

