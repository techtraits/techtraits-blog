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

This article is the second part of our series on some of the pitfalls of using Google App Engine for non-trivial applications and at significant scale. If you haven't already I encourage you to check out the [first article](http://techtraits.com/2013-02-24-The-problems-of-working-in-App-engine-I.html).

## Under-powered instances

The reason we were using GAE's APP Identity API for signing was that google instances are are greatly under-powered. This is not always obvious because most requests are not very CPU intensive and google launches a whole lot of servers so each one is rarely handling more that a few requests at a time. However, we were using RSA cryptography to sign our authorization tokens. I grant you that this is a CPU intensive task and we are willing to take the performance hit. However a quick benchmark showed that the signature generation takes on average 10ms on my rather modest laptop. The same code on a google app engine server under no load takes 400-600ms. This time does not include network latency or any scheduler overhead, this is just the time time taken to compute the signature.   

## Disconnect between services

Another thing that has me pulling out my hair is the complete disconnect between the various google services. This was highlighted when we needed to get data from our DataStore into Big Query for analysis. To get data into BigQuery you either need to upload it from your local machine or first copy it into Cloud Storage. While this is fine for manual operation but we are generating many gigabytes of data daily. Why is it necessary to copy it all to local storage and incur the network bandwidth cost and then load back into BigQuery and take that cost hit again. Data can be imported into BigQuery in two formats, CSV and JSON however data can only be exported in CSV format. We use a lot of JSON hence its very easy for us to write JSON to be ingested by BigQuery and the BigQuery certainly speaks JSON as it allows import of this format. Why is it arbitrarily denying export to JSON? Google has a detailed ACL mechanism to manage access to cloud storage however in order to authorize a user data access to BigQuery there is a completely separate authentication mechanism. Oh how I yearn for IAMs service on amazon. The ACLs on the cloud storage bucket can only be set using the appcfg.py tool which has to be run locally, the cloud storage access can only be setup using the API console. I could go on, it seams like no two services were designed to work with each other cleanly. 


The last thing I would like to highlight is the image above, for me it symbolizes what is wrong with GAE. Its a actual screen shot from a menu in GAE console for restoring backups. These backups were generated through google's standard tool and this is the User interface that allows you to select which up to restore from. The fact that some google developer somewhere wrote this UI looked at it and said "Sure, looks good you can select the backup you want lets ship it" scares me. It shows either an utter disregard for the usability of the server or more likely someone wrote the backup service which used random hashes as file names and assumed the restore code will look in the file for metadata and someone else wrote the restore code and assumed the file names would be human readable. Neither of these cases give me confidence that whats "under the hood" of google app engine has been thought through very well. This is important because you as a service developer are relying on GAE to have good plumbing under the hood as you have no control over it. If I had to write our service again I would probably go with Amazon Elastic Beanstalk or something less. For now it all kind of works and we are too far down this path so we will keep our fingers crossed. 



