--- 
layout: post
title: Using GAE TaskQueues for fun and profit. 
date: 2013-07-21 10:19:54
authors: 
- usman
categories: 
- System Design
tags:
- GAE
permalink: /pushqueue
---

Most web services have background operations that can be handled offline and the requesting client does not need to wait for their completion. You should be on the lookout for such flows in your service so you can greatly improve response times without sacrificing functionality. Dues to the nature of GAE's thread model long running background processes are not possible. Instead you use googles [Task Queue Service](https://developers.google.com/appengine/docs/java/taskqueue/), to store hooks which will trigger these offline processes. There are two types of Task Queue [Pull Queues](https://developers.google.com/appengine/docs/java/taskqueue/overview-pull) and [Push Queues](https://developers.google.com/appengine/docs/java/taskqueue/overview-push). This article walks you through setting up some task queues and  highlights their benefits and uses. 

Pull queues store all pending tasks until something (normally a GAE backend) request to pull some tasks off the queue. Push queues on the other hand actively push our tasks by making a request to a preconfigured URL for each task at a configured rate. 