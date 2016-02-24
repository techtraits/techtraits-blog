---
layout: post
title: Installing Jetty 9 on Linux systems
date: 2014-01-26 13:36:27
authors:
- usman
categories:
- System Design
tags:
- jetty
permalink: /jetty9install
---

Jetty is a light weight, flexible and feature rich Java server alternative to apache tomcat. Jetty 6 is available for installation through apt-get on debian systems however Jetty 6 is getting a bit long in the tooth. Several key features such as native support for continuations, support for the SPDY protocol and servlet 3 are missing in Jetty 6. This article covers the installation of [Jetty 9](http://www.eclipse.org/jetty/) on Linux.

## Install JDK

Jetty is implemented in Java and Jetty 9 requires the 1.7 JDK. You can install the JDK using yum or apt-get depending on whether you are on a Redhat/CentOS or Debian/Ubuntu distro.

{% highlight bash linenos %}
# For Redhat systems
yum install java-1.7.0-openjdk
# For debian Systems
apt-get install java-1.7.0-openjdk
{% endhighlight %}

## Get the Jetty Tarball

The next step is to download and unpack the [Jetty 9 tarball](http://download.eclipse.org/jetty/stable-9/dist/), the current latest stable version is 9.1.1.v20140108.tar.gz. Once you have the package untar it into the directory of your choice, I use opt for the jetty installation.

{% highlight bash linenos %}
cd /tmp
wget http://download.eclipse.org/jetty/stable-9/dist/jetty-distribution-9.1.1.v20140108.tar.gz
tar -xzvf jetty-distribution-9.1.1.v20140108.tar.gz
mv jetty-distribution-9.1.1.v20140108 /opt/jetty
{% endhighlight %}


## Create NPN Mapping
I have found the current latest distribution is missing the required npn module version which leads to the error shown below. If you get the error then copy the previous npn module file and create the required file as shown.

{% highlight bash linenos %}
starting Jetty: java.io.IOException: Cannot read file: modules/npn/npn-1.7.0_51.mod
	at org.eclipse.jetty.start.Modules.registerModule(Modules.java:405)
	at org.eclipse.jetty.start.Modules.registerAll(Modules.java:395)
	at org.eclipse.jetty.start.Main.processCommandLine(Main.java:561)
	at org.eclipse.jetty.start.Main.main(Main.java:102)

cp /opt/jetty/modules/npn/npn-1.7.0_45.mod /opt/jetty/modules/npn/npn-1.7.0_51.mod
{% endhighlight %}


## Create a user to run Jetty

It is recommended practice to run jetty as its own user and to do this we will create a jetty user.

{% highlight bash linenos %}
useradd jetty
chown -R jetty:jetty /opt/jetty
{% endhighlight %}


## Making Jetty into service

In order to make jetty into service which is started at run time we symlink the jetty.sh script into the init.d folder and setup a chkconfig entry.


{% highlight bash linenos %}
ln -s /opt/jetty/bin/jetty.sh /etc/init.d/jetty

chkconfig --add jetty
chkconfig jetty on
{% endhighlight %}


## Updating the startup script

Lastly, we need to update the jetty initialization script to setup the required parameters. Edit the jetty startup script in your editor of choice and add the following lines in the script.

{% highlight bash linenos %}
vim /etc/init.d/jetty

JETTY_HOME=/opt/jetty
JETTY_USER=jetty
JETTY_PORT=8080
JETTY_LOGS=/opt/jetty/logs/
{% endhighlight %}

## Testing

To test that all your changes worked start jetty and see if you can retrieve the index page.

{% highlight bash linenos %}
service jetty start
curl localhost:8080
{% endhighlight %}
