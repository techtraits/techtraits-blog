--- 
layout: post
title: Setting up a webservice using Guice & Sitebricks
wordpress_id: 135
wordpress_url: http://www.techtraits.ca/?p=135
author: usman
date: 2011-06-25 23:11:41 +00:00
categories: 
- Programming
- Java
tags:
- Java
- code
- Guice
- Sitebricks

---


This is a tutorial for java developers with some background in web technologies who want to learn how to bring up a web server. For this tutorial we will be using the <a href="http://jetty.codehaus.org/jetty/">Jetty 7</a> servlet container. The Jetty webserver is implemented entirely in java, hence can be easily embedded into Java applications. Furthermore, it is well supported by all of the common Java IDEs such as eclipse and supports most modern webserver technologies.  

<!--more-->

To write our user interface we will be using the <a href="https://github.com/dhanji/sitebricks">Sitebricks</a> framework from google. Sitebricks is somewhat similar to JSPs in that it allows you to integrate java code seamlessly with html front-ends. However, sitebricks is much easier to setup and use then JSPs. In addition sitebricks tend to be a lot less verbose than JSPs. 

We will be using the <a href="http://code.google.com/p/google-guice/">Guice 3</a> (pronounced "Juice") injection framework to make the code much cleaner and simpler. Guice allows us to generate a lot of functionality using annotations instead of writing code ourselves.  

To tie everything together we will be using <a href="http://maven.apache.org/download.html">Maven3</a>, which will manage all our dependencies as well as our build. That was a lot of technologies all at once and can sound scary if you are not familiar with them. Don't worry I will walk you through the process of integrating them. In addition you can download the <a href="http://www.techtraits.ca/wp-content/uploads/2011/06/helloworld.zip">Sample Project</a> source code here and see the project running. 

<h3>Tools of the trade</h3>

Lets get started, first download and install Java if you don't have it installed already. You can download the latest Java SDK <a href="http://www.java.com/en/download">here</a>. Once you have java installed please download and install Maven 3 from <a href="http://maven.apache.org/download.html">http://maven.apache.org/download.html</a>. You will find installation instructions on that page. You can verify that the installation was successful by opening a command line terminal and entering the mvn -version command. We now have everything we need to setup a web server.

{% highlight bash %}
mvn -version
Apache Maven 3.0.2 (r1056850; 2011-01-08 19:58:10-0500)
Java version: 1.6.0_24, vendor: Apple Inc.
Java home: /System/Library/Java/JavaVirtualMachines/1.6.0.jdk/Contents/Home
Default locale: en_US, platform encoding: MacRoman
OS name: "mac os x", version: "10.6.8", arch: "x86_64", family: "mac"
{% endhighlight %}
&nbsp;


<h3>Here's one I made earlier</h3>

If you would like to see the Web server we will be creating in action please download the source here:<a href='http://www.techtraits.ca/wp-content/uploads/2011/06/helloworld1.zip'>HelloWorld.zp</a>. Unzip this project and browse to the helloworld directory in your command line  terminal, run the following command and skip to step 10.

{% highlight bash %}
mvn clean install
mvn jetty:run-exploded
{% endhighlight %}
&nbsp;



<h3 style="text-align: justify;">Step 1: Creating the maven project</h3>

The first step is to create our maven pom.xml file. Maven is an automation framework which will manage our dependencies, compilation and deployment and a whole host of other tasks. Although it is possible to create the pom file from scratch we can leverage pre-built  templates (called archetypes) create our project pom.xml file. We can setup a web project using the maven webapp archetype. Open up a terminal window (or command prompt if you are on windows) and cd to directory where you would like to create your project and enter the following command. 

{% highlight bash %}
mvn archetype:generate 								\
  -DgroupId=com.flybynight.helloworld 				\
  -DartifactId=helloworld 							\
  -DarchetypeArtifactId=maven-archetype-webapp 	 	\
  -DarchetypeGroupId=org.apache.maven.archetypes 	\
  -Dversion=1.0-SNAPSHOT</pre>
{% endhighlight %}
&nbsp;



In this command we are specifying the location of location of our project in the maven project namespace with the "<strong>groupId</strong>" parameter. It is standard to use the inverse of your web domain as your group id.  for example if you work on a project called helloworld for a company called flybynight  which is hosted at www.helloworld.flybynight.com, you might use com.flybynight.helloworld as your group id. The "<strong>artifactId</strong>" parameter is a unique identifier for your project e.g. helloworld. The "<strong>archetypeArtifactId</strong>" and "<strong>archetypeGroupId</strong>" tell maven that you want to create an application using the "<strong>maven-archetype-webapp</strong>" template which can be found in the "<strong>org.apache.maven.archetypes</strong>" group.

After running this command you will see a lot of console output which is generated by maven downloading everything it needs to build your project. Eventually you should get the build success message shown below. You should now have a helloworld sub-directory in the current directory which contains a file <strong>pom.xml</strong> and a directory <strong>src</strong>. 


{% highlight bash %}
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 6.977s
[INFO] Finished at: Sat Jun 25 16:38:48 EDT 2011
[INFO] Final Memory: 7M/81M
[INFO] ------------------------------------------------------------------------
{% endhighlight %}
&nbsp;



<h3>Step 2: Settings up the compiler</h3>

The first thing we want to tell maven is where we will put our source files which we will do using the pom file. The pom file (helloworld/pom.xml) is the mission control of your maven application, it contains all settings, dependencies and deployment details. Open the pom file in a text editor of your choice and look for the <strong>&lt;build&gt;</strong> element and add the sourceDirectory element. There are many other settings you can update in the pom (<a href="http://maven.apache.org/guides/introduction/introduction-to-the-pom.html#Super_POM">Details</a>) but for now we will not edit them.

{% highlight xml %}
<sourceDirectory>src/main/java</sourceDirectory>
{% endhighlight %}
&nbsp;



<h3>Step 3: Settings up the Jetty</h3>

Next we need to tell maven that we will be using the Jetty webserver to host our content using the jetty plugin. 

We do that by adding a plugin tag with details of the jetty plugin in within the same build tag where put our source directory setting. A plugin definition for the current latest jetty plugin looks something like this:

{% highlight xml %}
<pre lang="xml">
<plugins>
	<plugin>
		<groupId>org.mortbay.jetty</groupId>
		<artifactId>jetty-maven-plugin</artifactId>
		<version>7.4.2.v20110526</version>
	</plugin>
</plugins>
{% endhighlight %}
&nbsp;


<h3>Step 4: Settings up the Jetty</h3>

We have now setup the framework to build and deploy our web server but we still need to include the Guice and Sitebricks libraries. Look for the <strong>&lt;dependencies&gt;</strong> element which tells maven what are the dependencies of our project. We depend on guice, sitebricks and also http components so we add the following dependencies. Maven will download and setup these for us and add them to the class path. 

{% highlight xml %}
<dependency>
	<groupId>com.google.inject</groupId>
	<artifactId>guice</artifactId>
	<version>3.0</version>
</dependency>
<dependency>
	<groupId>com.google.sitebricks</groupId>
	<artifactId>sitebricks</artifactId>
	<version>0.8.5</version>
</dependency>
<dependency>
    <groupId>org.apache.httpcomponents</groupId>
    <artifactId>httpclient</artifactId>
    <version>4.1.1</version>
    <scope>compile</scope>
</dependency>
{% endhighlight %}
&nbsp;


<h3>Step 5: Hooking up Guice</h3>

Now we must tell our application that we will be using Guice to intercept all http requests and manage all our content using google magic. For this open up the <strong>web.xml</strong> file (./src/main/webapp/WEB-INF/web.xml). In the <strong>&lt;web-app&gt; </strong>xml element add the code shown below. This creates a filter called <strong>webfilter</strong> which points to the google provided GuiceFilter class. We map the filter to "/*" which means all requests will go through guice. Lastly we tell guice to use the <strong>GuiceCreator</strong> class to figure out what to do with requests by setting the listener element to the fully qualified name of this class. In the nest section we will see how to implement this class so stay tuned. 

{% highlight xml %}
<filter>
    <filter-name>webFilter</filter-name>
        <filter-class>com.google.inject.servlet.GuiceFilter</filter-class>
    </filter>
<filter-mapping>
    <filter-name>webFilter</filter-name>
    <url-pattern>/*</url-pattern>
    </filter-mapping>
<listener>
    <listener-class>com.flybynight.helloworld.GuiceCreator</listener-class>
</listener>
{% endhighlight %}
&nbsp;


<h3>Step 6: Creating the Html Content</h3>

Now lets create the html front end for our sitebrick; all files that are to be deployed to our web server live in the src/main/webapp/ directory so we will create a HelloWorld.html file in there and add the following code. This has two components the "@ShowIf" annotation which tells sitebricks to show the following html element if a condition is met. We are setting the condition to always be true. Second we specify that we are looking for a message parameter from our sitebrick using the "<strong>${message}</strong>" tag. When serving the html page the sitebricks framework will parse the html and look for these tags. It will then query the corresponding brick for the value of this tag, e.g. for the message tag in HelloWorld.html sitebricks will call the <strong>getMessage</strong> method on the HelloWorld java class. Note that the naming is important because sitebricks uses case sensitive naming to match html files with their respective java classes. 

{% highlight html %}
<html>
<body>
    @ShowIf(true)
    <p>${message} from Sitebricks!
</body>
</html>
{% endhighlight %}
&nbsp;


<h3>Step 7: Creating the sitebrick</h3>

Now lets create the bick which provides the definition of the message tag in our Html code. I am using the <strong>com.flybynight.helloworld.sitebricks</strong> package for our sitebricks call so we will create a directory for the java file to live in. 

{% highlight bash %}
mkdir -p src/main/java/com/flybynight/helloworld/sitebricks/
{% endhighlight %}
&nbsp;


In that directory we will create the <strong>HelloWorld.java</strong> class, the code for which is shown below.  Note the "<strong>@At</strong>" annotation tells guice that this sitebrick should be served when the http request is for the "<strong>http://yourhostname/helloworld</strong>" url. The "<strong>getMessage</strong>" method is called by sitebrick to resolve the message parameter that we specified in the html as I mentioned earlier. 

{% highlight java %}
package com.flybynight.helloworld.sitebricks;

import com.google.inject.Inject;
import com.google.inject.name.Named;
import com.google.sitebricks.At;

@At("/helloworld")
public class HelloWorld {	
    public String getMessage() { 
    	return "Message";		
	}
}
{% endhighlight %}
&nbsp;


<h3>Step 8: Injecting a named proerpty</h3>

I would like to highlight the injection capabilities of Guice here; in your class create a property called messageString and annotate it with the <strong>Inject</strong> and <strong>named</strong> annotations. The named annotation takes a tag name as input, which is used to look up the value of the property. There are many other types of injection available See the <a href="http://code.google.com/p/google-guice/wiki/Injections">Guice Manual</a>. 



{% highlight java %}
package com.flybynight.helloworld.sitebricks;

import com.google.inject.Inject;
import com.google.inject.name.Named;
import com.google.sitebricks.At;

@At("/helloworld")
public class HelloWorld {

	@Inject
	@Named("message")
	String messageString;

    public String getMessage() { 
    	return this.messageString;		
	}
}
{% endhighlight %}
&nbsp;


<h3>Step 9: Configuring Guice Injection</h3>

In the <strong>src/main/java/com/flybynight/helloworld</strong> directory create a java file GuiceCreator.java and add the code shown below. The code tells Guice that we will be using sitebricks to host our content and that our sitebricks live in the package which contains the <strong>HelloWorld</strong> class. The scan call is telling Guice to ""scan" the classes in that package and look for the <Strong>@At</Strong> annotations to identify the brick classes. In addition we are providing the value of the property named <Strong>"message"</Strong> using the <Strong>bindConstant</Strong> method. 

{% highlight java %}
package com.flybynight.helloworld;

import com.flybynight.helloworld.sitebricks.HelloWorld;
import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.name.Names;
import com.google.inject.servlet.GuiceServletContextListener;
import com.google.inject.servlet.ServletModule;
import com.google.sitebricks.SitebricksModule;

public class GuiceCreator extends GuiceServletContextListener {

	@Override
	protected Injector getInjector() {
		Injector injector = Guice.createInjector ( 
				new SitebricksModule() {
			         protected void configureSitebricks() {
			                // scan class Example's package and all descendants
			                scan(HelloWorld.class.getPackage());
			                //Injection value of message
		                	bindConstant().annotatedWith(Names.named("message")).to("HelloWorld!!");
			            }
				}
		);
		return injector;
	}
}
{% endhighlight %}
&nbsp;


<h3>Step 10: All done now lets run it</h3>

And were are done, now we just compile everything, make sure the current directory is set to the one which contains the pom.xml file and run: 

{% highlight bash %}
mvn clean install
{% endhighlight %}
&nbsp;


You will see a lot of console output regarding maven downloading dependencies and then eventually a build successful message. 

{% highlight bash %}
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 3.318s
[INFO] Finished at: Sat Jun 25 18:30:53 EDT 2011
[INFO] Final Memory: 11M/81M
[INFO] ------------------------------------------------------------------------
{% endhighlight %}
&nbsp;


Now tell maven to run the webserver using the jetty plugin we configured earlier: <pre lang="bash">mvn jetty:run-exploded</pre> You should see more maven console output followed by <pre lang="bash">[INFO] Started Jetty Server</pre> which means your server is running. Fireup a browser and hit <a href="http://localhost:8080/helloworld">http://localhost:8080/helloworld</a>

<h3>Further Reading</h3>

If you have any problems leave a comment and I can update the article and if you would like for details of what we just did here you can read up on <a href="http://code.google.com/p/google-sitebricks/wiki/GettingStarted">Sitebricks</a>, <a href="http://code.google.com/p/google-guice/wiki/GettingStarted">Guice</a>, <a href="http://jetty.codehaus.org/jetty/">Jetty</a> and <a href="http://maven.apache.org/ref/3.0/">Maven</a>. 
