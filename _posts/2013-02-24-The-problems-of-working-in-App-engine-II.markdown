--- 
layout: post
title: The pitfalls of building services using Google App Engine -- Part II
date: 2013-02-24 17:09:00
author: bilal
categories: 
- System Admin
tags:
- GAE

---

Let us continue from where we [left off](http://techtraits.com/2013-02-24-The-problems-of-working-in-App-engine-I.html) and cover a few more major Google App Engine pitfalls when working with non-trivial applications at significant scale.

# Under-powered application front-end instances
The GAE instances are greatly under-powered. We had a simple use case where we used RSA cryptography to sign our authorization tokens. I grant you that it is a CPU intensive task and we are willing to take a performance hit. However, a quick benchmark showed that the signature generation takes on average 10ms on my Ubuntu VM with a couple of virutal cores on my rather modest laptop. The same code on Google App Engine under no load takes anywhere from 500 to 600ms. This time does not include network latency or any scheduler overhead, this is just the time time taken to compute the signature.    

A small benchmark for computing an RSA signature: 

    A VM on my laptop	 	 10ms
    GAE F1 (600MHz, 128MB)	 500-600ms
    GAE F2 (1200MHz, 256MB)	 450-500ms
    GAE F4 (2400MHz, 512MB)
    GAE F4 (2400MHz, 1GB)	

If you scour through Google groups, you will find that the best approach for doing something like this is to offload this work to an external service with more computational resources and then make an HTTP call. In fact GAE's [APP Indentity API](https://developers.google.com/appengine/docs/java/appidentity/) offers exactly this. However, the API has an arbitrary daily hidden quota of 1.84 Million calls ([see this](http://techtraits.com)) and there is no way of increasing it at the moment. 

# Under-performing Google Data Store and under-provisioned Cache
It would be fair to argue that most applications are not CPU intensive and spend a significant amount of time waiting on cache and the backend data store. 


## Disconnect between services

Another thing that has me pulling out my hair is the complete disconnect between the various google services. This was highlighted when we needed to get data from our DataStore into Big Query for analysis. To get data into BigQuery you either need to upload it from your local machine or first copy it into Cloud Storage. While this is fine for manual operation but we are generating many gigabytes of data daily. Why is it necessary to copy it all to local storage and incur the network bandwidth cost and then load back into BigQuery and take that cost hit again. Data can be imported into BigQuery in two formats, CSV and JSON however data can only be exported in CSV format. We use a lot of JSON hence its very easy for us to write JSON to be ingested by BigQuery and the BigQuery certainly speaks JSON as it allows import of this format. Why is it arbitrarily denying export to JSON? Google has a detailed ACL mechanism to manage access to cloud storage however in order to authorize a user data access to BigQuery there is a completely separate authentication mechanism. Oh how I yearn for IAMs service on amazon. The ACLs on the cloud storage bucket can only be set using the appcfg.py tool which has to be run locally, the cloud storage access can only be setup using the API console. I could go on, it seams like no two services were designed to work with each other cleanly. 


Neither of these cases give me confidence that whats "under the hood" of google app engine has been thought through very well. This is important because you as a service developer are relying on GAE to have good plumbing under the hood as you have no control over it. If I had to write our service again I would probably go with Amazon Elastic Beanstalk or something less. For now it all kind of works and we are too far down this path so we will keep our fingers crossed. 



