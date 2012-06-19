--- 
layout: post
title: Running Nexus Sontaype over Jetty
wordpress_id: 315
wordpress_url: http://www.techtraits.ca/?p=315
date: 2011-09-05 22:22:46 +00:00
categories: 
- Build Management
tags:
- Maven
- Nexus
- Sonatype
---
<p style="text-align: justify;">

If you are using Maven for build management you will very soon need to run a repository to store your artifacts and proxy remote artifacts so that your build is not blocked by external dependencies. Setting up a Nexus repository is as easy as deploying a war file to a web server. This tutorial covers the procedure for deploying the Nexus repository on a Jetty 6 web server.</p>

<!--more-->

<h3>Download Nexus war file</h3>

<p style="text-align: justify;">Nexus is distributed as a war file which can be downloaded at <a title="http://nexus.sonatype.org/downloads/" href="http://nexus.sonatype.org/downloads/" target="_blank">http://nexus.sonatype.org/downloads/</a>. I used version 1.9.2 which can be downloaded from <a title="http://nexus.sonatype.org/downloads/nexus-webapp-1.9.2.2.war" href="http://nexus.sonatype.org/downloads/nexus-webapp-1.9.2.2.war" target="_blank">Here</a>. Rename the downloaded file to something simpler such as nexus.war.</p>



<h3>Download and Setup Jetty</h3>

<p style="text-align: justify;">

Now download Jetty six from here <a title="http://dist.codehaus.org/jetty/" href="http://dist.codehaus.org/jetty/" target="_blank">http://dist.codehaus.org/jetty/</a>. I used version 6.1.26 which can be downloaded from <a title="Jetty 6.1.26" href="http://dist.codehaus.org/jetty/jetty-6.1.26/jetty-6.1.26.zip" target="_blank">Here</a>. Unzip jetty into a folder of your choice and browse to the "contexts" directory. Create a file here called nexus with the text shown below. The contextPath element specifies the context by which users will find the application on your server, e.g. http://[domain-name]/nexus/. The war element specifies the location of the WAR file inside the Jetty home directory, under the standard webapps folder, using a WAR file called nexus.war.</p>


{% highlight erlang %}
<?xml version="1.0"  encoding="ISO-8859-1"?>

<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">

<configure class="org.mortbay.jetty.webapp.WebAppContext">

    <set name="contextPath">
    	/nexus
    </set>
    <set name="war">
    	<systemproperty name="jetty.home" default="."/>/webapps/nexus.war
    </set>

</configure>

{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

Now copy the Sonatype nexus war file into the webapps directory in the jetty base directory.</p>

<h3>Running Jetty</h3>

<p style="text-align: justify;">

Open a terminal instance at the jetty root directory and run the following command to start jetty.</p>

	java -jar start.jar

<p style="text-align: justify;">This should start your Nexus repository in the Jetty container. Fire up your favorite browser and go to http://[domain]:8080/nexus/ or http://localhost:8080/nexus/ if you are running Nexus on your local machine. You should be presented with the nexus front end and can start managing your repositories.</p>

<p style="text-align: justify;">Note: The default admin user and password are "admin" and "admin123" respectively.</p>



<h3>Further Reading</h3>

<p style="text-align: justify;">

Please see the <a href="http://www.sonatype.com/books/nexus-book/reference/" title="http://www.sonatype.com/books/nexus-book/reference/" target="_blank">Nexus docs</a> for details on how to create and manage maven repositories. 
