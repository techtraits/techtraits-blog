--- 
layout: post
title: Setting up Seyren in a docker container
date: 2014-07-09 12:51:26
authors: 
- usman
categories: 
- system design
tags:
- docker
- Seyren
permalink: /Seyrendocker
---
We belive strongly in the measure everything philosophy of server management and because of this we have a lot of metrics about our system. One of the ways we make use of this data is to create real time alerts that allow us quickly identify and respond to production issues. For this we make extensive use of a tool called [Seyren](https://github.com/scobal/seyren) to create and manage real-time alerts for our server deployments. This article walks you through setting up a Seyren instance using the [docker](https://docker.com/) platform. We use docker because it provides us a way of repeatably deploying a Seyren instance and requisite MongoDB quickly.

## MongoDB Setup

Seyren uses MongoDB for datastore so before we setup Seyren we need to bring up a MongoDB container. The basic command for running a named mongo container is shown below. We specify the __-d__ switch to run in daemon mode so that it remains running when we bring up other containers. We also use the __--name__ switch to tag the container with a name of our choosing. Alternatively we can also the __-v__ switch to map a local directory to the /data/db directory. This allows you to easily backup and archive the alerts setup in your Seyren instance.  

{% codeblock  Maven Pom Build lang:bash %}
# Run MongoDB
docker run -d --name mongodb dockerfile/mongodb

# Alternatively Run MongoDB with specified volume
docker run -d -v <local-data-dir>/db:/data/db --name mongodb dockerfile/mongodb
{% endcodeblock %}

## Setting up Seyren

To run a basic Seyren instance we run the following command, which downloads and runs the __usman/docker-seyren__ container image. We expose the port 8080 using the __-p__ command, and use the __--link__ switch to link the MongoDB container with this new container. Linking allows the two containers to communicate over a virtual network securely such that no other machine or container can communicate with this MongoDB instance. Since this container is running in daemon mode you will need to use the docker logs command to see if Seyren came up successfully. 

{% codeblock  Maven Pom Build lang:bash %}
# Run Seyren and link MongoDB
docker run -d -p 8080:8080 --name seyren --link mongodb:mongodb -i -t usman/docker-seyren http://[GRAPHITE_URL]

# Look at Seyren Logs
docker logs -f seyren

Graphite URL http://[GRAPHITE_URL]
Mongo URL mongodb://172.17.0.50:27017/seyren
java version "1.7.0_55"
OpenJDK Runtime Environment (IcedTea 2.4.7) (7u55-2.4.7-1ubuntu1)
OpenJDK 64-Bit Server VM (build 24.51-b03, mixed mode)
Jul 07, 2014 9:24:51 AM org.apache.coyote.AbstractProtocol init
INFO: Initializing ProtocolHandler ["http-bio-8080"]
Jul 07, 2014 9:24:51 AM org.apache.catalina.core.StandardService startInternal
INFO: Starting service Tomcat
Jul 07, 2014 9:24:51 AM org.apache.catalina.core.StandardEngine startInternal
INFO: Starting Servlet Engine: Apache Tomcat/7.0.37
Jul 07, 2014 9:24:56 AM org.apache.catalina.core.ApplicationContext log
INFO: No Spring WebApplicationInitializer types detected on classpath
Jul 07, 2014 9:24:57 AM org.apache.catalina.core.ApplicationContext log
INFO: Initializing Spring root WebApplicationContext
Jul 07, 2014 9:25:00 AM org.apache.coyote.AbstractProtocol start
INFO: Starting ProtocolHandler ["http-bio-8080"]
{% endcodeblock %}

You should now be able to access Seyren on [http://localhost:8080/](http://localhost:8080/) or if you are using boot2docker then on [http://192.168.59.103:8080/](http://192.168.59.103:8080/). On OSX you would need to forward traffic from the public interface to the internal docker VM to use this Seyren instance from other machines.

{% image /assets/images/seyren.png style="float:center" alt="Docker Installer" class="pimage" height="220" width="500" %} 

