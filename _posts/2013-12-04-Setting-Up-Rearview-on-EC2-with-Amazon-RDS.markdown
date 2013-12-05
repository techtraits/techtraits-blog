--- 
layout: post
title: Setting up Rearview on EC2 with Amazon RDS
date: 2013-12-04 21:27:22
authors: 
- bilal
categories: 
- Monitoring
- Alerting
- Metrics
tags:
- graphite
- rearview
- seyren
- metrics
- ec2
- rds
- ses
- amazon
permalink: /rearview-ec2-rds
---

My team at EA loves [Graphite](http://graphite.wikidot.com/), and as a rule, all services we write must be instrumented to report metrics to Graphite. We rely on the excellent [Codahale metrics](http://metrics.codahale.com/) library for all Java projects. Reporting metrics to Graphite is only the first step. To enable round-the-clock monitoring and incident detection, the next step is to setup monitors that are triggered automatically when certain criteria are met. For example, when the 95th percetile response time for a service exceeds a pre-defined threshold. For such incidents, an email is sent to a mailing list and an incident is created with [PagerDuty](http://www.pagerduty.com/) to notify the on-call person. So far we have been using [Seyren](https://github.com/scobal/seyren) for alerting. The good thing about Seyren is that it has a very straightforward dashboard for setting up alerts on Graphite metrics. However, we have seen quite a few stability issues in production and we ended up spending quite a bit of time automating Seyren deployments for game teams, fire-fighting when Seyren crashed, stopped triggering alerts or when MongoDB process died.

### Meet Rearview

Because of all these issues we were on the lookout for a replacement for Seyren. Recently, folks at [LivingSocial](http://livingsocial.com) open sourced [Rearview](http://steveakers.com/2013/08/15/rearview-real-time-monitoring-with-graphite/): a framework for alerting on Graphite metrics in real-time. Although, the documentation is little sparse, it was easy to set up Rearview in parallel to our production instance of Seyren. And after a couple of weeks of Rearview running side-by-side with Seyren, I'm happy to report that Rearview has worked well without any stability issues or missed alerts. To share the love, in this article I'm going to outline the process of setting up Rearview on an EC2 instance with Amazon RDS and SES. 



### Step 1: Creating a Security Group in Amazon

The first step is to create a security group for Rearview. Log into AWS console, select `EC2` from services and `Security Groups` from the left menu. Create a new security group for Rearview. 

{% image /assets/images/rearview-setup-security-group-2.png alt="Rearview Security Group" class="pimage" %}

Add rule for SSH and allow public access to port 9000 (the default port for Rearview). If you want, you can restrict access to port 9000 to only your organization by specifying an ip range. Here's what the rules look like: 

{% image /assets/images/rearview-setup-security-groups-3.png alt="Rearview Security Group Rules" class="pimage" width="100%" %}

### Step 2: Launch an EC2 instance

Next we launch a new instance by clicking `Launch New Instance` from the EC2 menu. I picked Ubunto Server 12.04 LTS - ami-a73264ce (64-bit): 

{% image /assets/images/rearview-setup-launch-instance-1.png alt="Rearview Launch Instance" class="pimage" width="100%" %}

Select the instance type. Medium general purpose instance would be a reasonable choice. Continue with the setup and remember to select "Rearview" as the security group in "Step 6: Configure Security Group". Review the setup and launch the instance. It will prompt you to create key pair. Create a a new one for Rearview. Download the key pair and don't lose it, you will need the key to SSH into your instance. 

{% image /assets/images/rearview-setup-instance-setup-3.png alt="Rearview Instance Setup 3" class="pimage" width="100%" %}

### Step 3: Install Software

Once the instance is ready. ssh into it and install the following dependencies and utilities:

{% codeblock Asset Index lang:bash %}

	#set permissions for rearview key
	chmod 400 rearview.pem

	ssh -i rearview.pem ubuntu@ec2-xx-yyy-zzz-tt.compute-1.amazonaws.com

	#Update the package list since the AMI is quite old
	sudo apt-get update

	#Install make:
	sudo apt-get install make

	#Ant and Ivy:
	sudo apt-get install ant ant-doc ant-optional
	sudo apt-get install ivy ivy-doc

	#Java JDK & JRE:
	sudo apt-get install openjdk-6-jdk openjdk-6-jre-headless openjdk-6-jre-lib

	#Ruby:
	sudo apt-get install ruby1.9.1-full

	#JSON ruby gem
	sudo gem install json

	#Git:
	sudo apt-get install git

	#Screen
	sudo apt-get install screen

{% endcodeblock %}

Typically the best practice is to install Ruby Version Manager (RVM) and use RVM to install rubies. Since I only plan to use the instance for Rearview, it is alright to do a system-wide installation of ruby. Lastly, install MySQL, setup root user's credentials and create a database for testing:

{% codeblock Asset Index lang:bash %}

	#Install MySQL client and server:
	sudo apt-get install mysql-client mysql-server

	#specify the root user's password when prompted

	#Create the database used for tests. We'll create the production database in RDS 
	mysql -u root -p

	create database rearview_test;

	exit;

{% endcodeblock %}

### Step 4: Get Rearview and run tests

{% codeblock Asset Index lang:bash %}
	
	#Get rearview:
	git clone git://github.com/livingsocial/rearview.git

	cd rearview

{% endcodeblock %}

In `conf/common.conf` set the username and password for the database. Don't modify the database url.

{% codeblock Asset Index lang:bash %}

	# Database configuration
	# ~~~~~
	# You can declare as many datasources as you want.
	# By convention, the default datasource is named `default`
	#
	db.default.driver="com.mysql.jdbc.Driver"
	db.default.url="jdbc:mysql://localhost:3306/rearview"
	db.default.user="root"
	db.default.password="ROOT_USER_PASS"
{% endcodeblock %}

We are now ready to run the test suites and verify that everything is in order:

{% codeblock Asset Index lang:bash %}

	./sbt test
{% endcodeblock %}

It will download a bunch of dependencies and run tests. Will take some time. If all is setup and Rearview can connect with the local "rearview_test" db, you will see output indicating that all tests passed. 

**Note:** This would be a good time to create an AMI with all depencies and Rearview installed. Remember to [remove any unwanted ssh keys](http://blog.sendsafely.com/post/59101320815/avoiding-residual-ssh-keys-on-ubuntu-amis) before creating an AMI. 

### Step 5: Set up RDS and production Rearview database

Since Rearview can talk with any MySQL database, the easiest setup is to you can create a "rearview" database on the EC2 instance when creating the "rearview_test" database. The problem with that approach is that if the instance goes down, you will lose all your monitors and applications from Rearview. One approach is to use EBS backed instances so that if the instance goes dowm, the EBS volume can be mounted and the data restored. I much prefer setting it up with RDS with automatic daily backups turned on. This way even if the instance goes down, we can launch another one without manually trying to restore data from EBS volumes. 


In AWS console, from services select "RDS" and click launch a DB instance and select "MySQL". Select instance type, specify master username and password. 

{% image /assets/images/rearview-setup-rds-setup-1.png alt="Rearview RDS setup 1" class="pimage" width="100%" %}

Set the default database as "rearview", select the default DB security group, review and launch the instance.  


{% image /assets/images/rearview-setup-rds-setup-2.png alt="Rearview RDS setup 2" class="pimage" width="100%" %}

Update the default DB security group and add rule:


<cite>CIDR/IP: 0.0.0.0/0</cite>

Wait for the database instance to launch and test connectivity using MySQL client or MySQL Workbench.

### Step 6: Set up SES for sending emails

From services select "SES", then select verified senders and add a new verified sender by following the steps. Rearview will use this email for sending alerts. Then select SMTP settings and click "Create My SMTP credentials". It will prompt you to create a new IAM user for SES. Create the IAM user and download the credentials:

{% image /assets/images/rearview-setup-ses-setup-1.png alt="Rearview SES setup 1" class="pimage" width="100%" %}

### Step 7: Configure Rearview

Before we can run Rearview in production we have to setup some configuration properties. Update the following properties in `conf/common.conf`:

+ Point to RDS:

{% codeblock Asset Index lang:bash %}

	db.default.driver="com.mysql.jdbc.Driver"
	db.default.url="jdbc:mysql://XXXXX.YYYY.us-east-1.rds.amazonaws.com:3306/rearview"
	db.default.user="root"
	db.default.password="PASSWARD"
	
{% endcodeblock %}

+ Setting Google openId domain:

{% codeblock Asset Index lang:bash %}

	sopenid.domain="ea.com"

{% endcodeblock %}

+ Disable statsd:

{% codeblock Asset Index lang:bash %}

	#You can install statsd on the EC2 instance and enable it if you like
	statsd.enabled=false

{% endcodeblock %}

+ Graphite properties:

{% codeblock Asset Index lang:bash %}

	graphite.host="https://your_graphite_host/"
	
	#if your graphite instance is not password protected, leave auth as "". 

	graphite.auth="AUTH" 

	#where AUTH = base64(username + ":" + password)

	#so for example if your username = "user" and password = "pass"
	AUTH=base64("user:pass") => "dXNlcjpwYXNz"

{% endcodeblock %}

+ Email properties:

{% codeblock Asset Index lang:bash %}

	email.from="bilal@ea.com"
	email.host="email-smtp.us-east-1.amazonaws.com"
	email.port=25
	# set the username and password you got for the SES IAM use in Step 6
	email.user="USER_NAME"
	email.password="PASSWORD"

{% endcodeblock %}

+ Update service.hostname:

{% codeblock Asset Index lang:bash %}

	service.hostname="your-rearview-hostname:9000"

{% endcodeblock %}


+ Enable email alerts:

{% codeblock Asset Index lang:bash %}

	alert.class_names = ["rearview.alert.LiveEmailAlert"]

{% endcodeblock %}

### Step 8: Start Rearview in Screen

At this point we are ready to start Rearview. We are going to run Rearview in a screen session to ensure that the Rearview process keeps running even after our ssh session ends: 

{% codeblock Asset Index lang:bash %}

	screen
	./sbt start
	# CTRL+d to exit logging mode
	# detach from screen: CTRL+A and then d

	#Re-attaching to the screen:

	#screen -ls to list all screen sessions and then
	#screen -r <session> to re-attach to a session

{% endcodeblock %}
 
