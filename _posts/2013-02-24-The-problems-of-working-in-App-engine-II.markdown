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
The GAE instances are greatly under-powered. We had a simple use case where we used RSA cryptography to sign our authorization tokens. I grant you that it is a CPU intensive task and we are willing to take a performance hit. However, a quick benchmark showed that the signature generation takes on average 10ms on my Ubuntu VM on my rather modest laptop. The same code on Google App Engine under no load takes anywhere from 500 to 600ms. This time does not include network latency or any scheduler overhead, this is just the time taken to compute the signature.    

A small benchmark for computing an RSA signature: 
    A VM on my laptop	 	 10ms
    GAE F1 (600MHz, 128MB)	 500-600ms
    GAE F2 (1200MHz, 256MB)	 450-500ms
    GAE F4 (2400MHz, 512MB)	 350-450ms

If you scour through Google groups, you will find that the recommended approach for doing something like this is to offload this work to an external service with more computational resources and then make an HTTP call. In fact GAE's [APP Indentity API](https://developers.google.com/appengine/docs/java/appidentity/) offers exactly this. However, the API has an arbitrary daily hidden quota of 1.84 Million calls ([see this](http://techtraits.com)) and there is no way of increasing it at the moment. 

# Under-performing Google Data Store and under-provisioned Cache
It would be fair to argue that most web applications are not CPU intensive and spend a significant amount of time waiting on cache and the backend data store. It would be nice then to have a fast data store and cache layer. Unfortunately, the google data store is quite slow. Indexed reads take anywhere from 150ms to 250ms under modest load and writes range from 300ms to over 500ms on occasions. We have seen these latencies when dealing with approximately 1500 requests per seocnd sent to one of our services by [Simpsons Tapped Out](https://play.google.com/store/apps/details?id=com.ea.game.simpsons4_na). 

These latencies mandate that everything that can be cached must be cached. Fortunately, Google Cache is reasonably fast and the latencies range from as low as 10ms to a typical of 20-40ms. Here's the kicker: the cache is automatically scaled out/back by Google a number of times in a day for a service under load. What this essentially does is that it invalidates a good chunk of the cached data, generally resulting in response time spikes and leads to service instability.  I can't think of any reason why cache is being provisioned for exact fit. Cache provides a layer of stability for the service and serves as the only safegaurd for protecting the less elastic backend data store. 


Neither of these cases give me confidence that whats "under the hood" of google app engine has been thought through very well. This is important because you as a service developer are relying on GAE to have good plumbing under the hood as you have no control over it. If I had to write our service again I would probably go with Amazon Elastic Beanstalk or something less. For now it all kind of works and we are too far down this path so we will keep our fingers crossed. 



