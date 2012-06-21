--- 
layout: post
title: Creating executable jars with Maven
wordpress_id: 703
wordpress_url: http://www.techtraits.ca/?p=703
date: 2011-12-17 06:48:03 +00:00
author: usman
categories: 
- Build Management
tags:
- Maven
- Assembly Plugin
---
<p style="text-align: justify;">

One really useful task that one of my junior devs recently asked my help with was to create an executable jar from a maven project. He had mostly figured it out on his own but I still think this is a useful topic to cover. To achieve this we will be using the <a href="http://maven.apache.org/plugins/maven-assembly-plugin/" title="Maven assembley plugin" target="_blank">Maven Assembly plug-in</a> running in Maven 3.</p>



<!--more-->

<p style="text-align: justify;">

As a starting point I will use code I wrote to go along with an earlier article <a href="http://www.techtraits.ca/five-minute-guide-to-setting-up-a-java-webserver/" target="_blank">Setting up a webservice using Guice & Sitebricks</a>. The code is available <a href="http://www.techtraits.ca/wp-content/uploads/2011/06/helloworld.zip" target="_blank">here</a>. First lets go and create our main class, Please add a Java class file at <font color="green">helloworld/src/main/java/com/flybynight/helloworld</font> and add the following code to let us know or jar was packed properly.</p> 



{% highlight java %}
package com.flybynight.helloworld;

public class Driver {
	public static void main(String[] args) {
		System.out.println("Hello");
	}
}
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

Next create a manifest file for your executable jar at <font color="green">src/main/resources/META-INF/MANIFEST.MF</font> and add set the main class parameter to the Driver class we just wrote by adding the following text <font color="green">Main-Class: com.flybynight.helloworld.Driver</font>.</p>



<p style="text-align: justify;">

Now create a assembly description file for you project, create a file at <font color="green">src/assemble/descriptor.xml</font> and add the text below. We are defining an assembly execution called exe which will create an executable jar in the target directory. A detailed description of all the parameters in the descriptor file can be found <a href="http://maven.apache.org/plugins/maven-assembly-plugin/assembly.html" title="Assembly Usage" target="_blank">here</a>.</p>

{% highlight xml %}
<assembly>
  <id>exe</id>
  <formats>
    <format>jar</format>
  </formats>
  <includeBaseDirectory>false</includeBaseDirectory>
  <dependencySets>
    <dependencySet>
      <outputDirectory></outputDirectory>
      <outputFileNameMapping></outputFileNameMapping>
      <unpack>true</unpack>
      <scope>runtime</scope>
      <includes>
      </includes>
    </dependencySet>
  </dependencySets>
  <fileSets>
    <fileSet>
      <directory>target/classes</directory>
      <outputDirectory></outputDirectory>
    </fileSet>
  </fileSets>
</assembly>
{% endhighlight %}
&nbsp;



<p style="text-align: justify;">

We are almost done now the last step is to add the maven assembly plug-in definition to our pom.xml file. Find the plugins tag in the xml and add the following lines here. Notice how we are referencing the manifest and descriptor file here. </p>



{% highlight xml %}
<plugin>
    <artifactId>maven-assembly-plugin</artifactId>
    <version>2.2.2</version>
    <configuration>
        <descriptors>
            <descriptor>src/assemble/descriptor.xml</descriptor>
        </descriptors>
        <archive>
            <manifestFile>src/main/resources/META-INF/MANIFEST.MF</manifestFile>
        </archive>
    </configuration>
</plugin>
{% endhighlight %}
&nbsp;




<p style="text-align: justify;">

Now to test your code run the <font color="green">mvn assembly:assembly</font> target to generate the execute the assembly plugin. You should now see the target/helloworld-exe.jar file. To test the jar run <font color="green">java -jar target/helloworld-exe.jar</font>. You should see "hello" printed to console.</p>



<h3>Source code</h3>

The source code for this project is released under the <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/Licensing.txt'>BSD License</a> and can be downloaded at <a href='http://www.techtraits.com/wp-content/uploads/2011/12/helloworld.zip'>helloworld</a>.



mvn assembly:assembly
