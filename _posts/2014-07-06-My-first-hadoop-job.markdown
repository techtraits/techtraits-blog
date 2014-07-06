--- 
layout: post
title: Setting up my first hadoop cluster
date: 2014-07-06 14:38:45
authors: 
- usman
categories: 
- programming
tags:
- hadoop
permalink: /hadoopstart
---

Big Data is a very common word that is thrown about in tech circles these days, almost every mid to large sized company wants to get use Big Data analysis to solve all their problems. Although I take such proclamations of holy grail with a pinch of salt I would like to have first hand knowledge of implementing a Big Data solution. [Apache Hadoop](http://hadoop.apache.org/) is the most commonly used Big Data platform. In a series of articles I will cover Hadoop deployments of increasing complexity. This article will walk you through the process of bringing up a single-node pseudo-cluster and writing a simple map reduce job to run on the cluster. Subsequent articles will cover topics such as setting up multi-node clusters, the use of [Apache Hive](https://hive.apache.org/) for data warehousing, the use  of [Apache Flume](http://flume.apache.org/) and [Apache Sqoop](http://sqoop.apache.org/) for data ingest and lastly [Apache Oozie](http://oozie.apache.org/) for workflow management. 

{% image /assets/images/docker_whale.png style="float:right" alt="Docker.io" class="pimage" %}