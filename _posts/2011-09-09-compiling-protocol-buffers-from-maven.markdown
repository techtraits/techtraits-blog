--- 
layout: post
title: Compiling Protocol Buffers from Maven
wordpress_id: 289
wordpress_url: http://www.techtraits.ca/?p=289
author: usman
date: 2011-09-09 19:46:43 +00:00
categories: 
- Build Management
- Maven
tags:
- Maven
- Protocol Buffers
---
<p style="text-align: justify;"><a title="Protocol Buffer" href="http://code.google.com/p/protobuf/" target="_blank">Protocol buffer</a> is a technology made by google for automatic serialization of data to and from a compressed binary format. Essentially you define your data in a <strong>I</strong>nterface <strong>D</strong>efinition <strong>L</strong>anguage <a title="IDL" href="http://en.wikipedia.org/wiki/IDL_%28programming_language%29" target="_blank">(IDL)</a> and then generate bindings for any language from which you want to generate the data or consume data. It is very similar to <a title="Thrift" href="http://thrift.apache.org/" target="_blank">Thrift</a> in philosophy and function except that Thrift provides network transport as well as serialization.</p>

<!--more-->

<p style="text-align: justify;">As with all code generation frameworks the first problem we need to tackle is how to efficiently integrate the code generation into our build pipeline. There some important requirements for such an integration. First, the generated code should not be checked in manually or if possible it should not be checked in at all as this will lead to frustration later. Developers will forget to checking generated files, overwrite each others' changes as generate code tends to be verbose and unfamiliar to the user. Second, the generated code should be available for debugging otherwise development around the generated code will be frustrating and slow. Third, incompatible changes to the source IDL files should break the build. Last, people who do not need to edit the IDL files should not have to generate the code locally as this will be another piece of tech they will maintain.</p>

<p style="text-align: justify;">To support all of these requirements I use a <a title="Maven" href="http://maven.apache.org/" target="_blank">Maven</a> based build pipeline with a <a title="Nexus Sonatype" href="http://nexus.sonatype.org/" target="_blank">Nexus Sonatype repository</a> for storing artifacts which can then be used for all developers in their local builds. This tutorial will give a step by step guide to setting up such a project. Note this tutorial is only compatible with Linix/Unix systems or cygwin if you are on windows</p>



<h3 style="text-align: justify;">Tools of the trade</h3>

Before going further you will need to install the following tools.

<p style="text-align: justify;">
<strong>Java 6 SDK. </strong>The first step is to download and install <a title="http://www.java.com/en/download/" href="http://www.java.com/en/download/" target="_blank">Java</a> in this tutorial we will be generating code for Java and C++.</p>

<p style="text-align: justify;">
<strong>Maven 3.</strong> Next we download and install <a title="http://maven.apache.org/download.html" href="http://maven.apache.org/download.html" target="_blank"> Apache Maven 3</a>. The installation process is simple enough and I won't get into the details. Please feel free to ask questions in the comments or the forum if you get stuck.</p>


{% highlight bash %}
# Run this command to check the correct version of Maven is installed, in the path
$mvn  --version
# It should echo the following line among other output.
Apache Maven 3.X.X ....
{% endhighlight %}
&nbsp;


<p style="text-align: justify;"><strong>Nexus Repository.</strong> You will need to setup a nexus repository in order to share the packaged, generated sources between developers. I have created a simple tutorial on setting up a Nexus repository. <a title="Setting up Nexus Repository " href="http://www.techtraits.ca/?p=315" target="_blank">Here</a></p>

<p style="text-align: justify;"><strong>Protocol Buffer Compiler.</strong> You will need to install the protocol buffer compiler which can be downloaded <a title="http://protobuf.googlecode.com/files/protobuf-2.4.1.tar.bz2" href="http://protobuf.googlecode.com/files/protobuf-2.4.1.tar.bz2">here</a>. Detailed installation instructions for the protocol buffer compiler can be found <a title="http://code.google.com/p/protobuf/source/browse/trunk/INSTALL.txt" href="http://code.google.com/p/protobuf/source/browse/trunk/INSTALL.txt" target="_blank">here</a>. However, the basic steps are to untar the package, browse to the directory in the terminal or cygwin and run the following commands.</p>


{% highlight bash %}
./configure
make
sudo make install
protoc --version
{% endhighlight %}
&nbsp;

<p style="text-align: justify;"><strong>Maven Protoc Plugin</strong> In order to compile protocol buffer you would need to compile and install the Maven Protoc Plugin (Full disclosure: I am a contributor to the plugin). The source is available on github at <a title="https://github.com/usmanismail/maven-protoc-plugin" href="https://github.com/usmanismail/maven-protoc-plugin" target="_blank">https://github.com/usmanismail/maven-protoc-plugin</a> or you can download the source <a href="http://www.techtraits.ca/wp-content/uploads/2011/09/maven-protoc-plugin.zip">here</a>. Unzip the package and run the following commands to compile the plugin</p>


{% highlight bash %}
cd maven-protoc-plugin
mvn clean install
{% endhighlight %}
&nbsp;

<h3>Creating maven project</h3>

<p style="text-align: justify;">We will be keeping our protocol buffer IDL files in a maven project which will be deployed to the Nexus repository we just setup. We keep our IDL files a little maven project of its own so to ensure the four requirements for integration that we specified in the start of this tutorial. I will highlight how we fulfill each requirement as we go. To create a simple Maven java project run the following command:</p>


{% highlight bash %}
   mvn archetype:generate                         \
	  -DgroupId=com.flybynight.protobuff          \
	  -DartifactId=protocompiler                  \
	  -DarchetypeArtifactId=java-1.6-archetype    \
	  -DarchetypeVersion=0.0.2                    \
	  -DarchetypeGroupId=net.avh4.mvn.archetype   \
	  -Dversion=1.0-SNAPSHOT
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">This will create a base project for you called "protocompiler" if you cd to the newly created directory you should be able to see that it already contains a src folder and a pom.xml file.</p>

{% highlight bash %}
cd protoccompiler
ls -l
-rw-r--r--  1 usman  staff  1637  5 Sep 19:02 pom.xml
drwxr-xr-x  4 usman  staff   136  5 Sep 19:02 src
{% endhighlight %}
&nbsp;

<h3>Writing your Proto Files</h3>

<p style="text-align: justify;">cd to src/main/resources and create a new file called hello.proto and add the following text:</p>


{% highlight bash %}
message HelloWorld {
  required string message = 1;
}
{% endhighlight %}
&nbsp;

We can test out protocol buffer compiler installation and that our file is valid by running the command shown below. It will generate the Hello.java file.

{% highlight bash %}
protoc -I=./ --java_out=./ hello.proto
ls -l
{% endhighlight %}
&nbsp;

<h3>Generating Source Files</h3>

<p style="text-align: justify;">

Now we get to the automatic generation of the source files which we do using the maven-protoc-plugin we installed earlier. Open the pom file at protoccompiler/pom.xml, look for the "dependencies" element and add the following dependency to pull in protocol buffer support files.</p>

{% highlight xml %}
<dependency>
    <groupId>com.google.protobuf</groupId>
    <artifactId>protobuf-java</artifactId>
    <version>2.4.1</version>
</dependency>
{% endhighlight %}
&nbsp;
<p style="text-align: justify;">

Now look for the "plugins" element and add the plugin definition below. We are invoking the "maven-protoc-plugin" that we compiled earlier in the tutorial by specifying its groupId and artifactId. In the configuration section we are specifying the protocol buffer compiler binary using "protocExecutable". Note that this assumes that protoc is in the path. If this is not the case you can specify the fully qualified path to the binary. Using "protoSourceRoot" we are specifying the location of the proto files. The plugin looks for files in the specified directory with the ".proto" extension. We are then specifying that we wish to generate sources for Java and C++ using the "JAVA" and "CPP" constants respectively. For each language we also specify a output directory where the generated source will be placed.</p>

{% highlight xml %}

<plugin>
    <groupId>com.google.protobuf.tools</groupId>
    <artifactId>maven-protoc-plugin</artifactId>
    <version>0.1.11-SNAPSHOT</version>
    <configuration>
        <protocExecutable>protoc</protocExecutable>
        <protoSourceRoot>${project.basedir}/src/main/resources/</protoSourceRoot>
        <languageSpecifications>
            <LanguageSpecification>
               <language>JAVA</language>
               <outputDirectory>
               		${project.basedir}/target/generated-sources/java
               </outputDirectory>
            </LanguageSpecification>
	    <LanguageSpecification>
	        <language>CPP</language>
        	<outputDirectory>
        		${project.basedir}/target/generated-sources/cpp
        	</outputDirectory>
	    </LanguageSpecification>
        </languageSpecifications>						
    </configuration>
    <executions>
        <execution>
            <goals>
                <goal>compile</goal>
            </goals>
        </execution>
    </executions>
</plugin>
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">

Once you make the changes save the pom file and compile the project using the mvn clean install command. You should see the generated sources in target/generated-sources/java and target/generated-sources/cpp. Furthermore the generated jar file contains the generated java sources as compiled class files. This fulfills our first requirement that the generated files should not have to be checked in (as they will be available in the jar file). </p>



<h3>Attach source</h3>

<p style="text-align: justify;">

To fulfill our requirement of generated code being easy to debug we will attach a source jar to our artifact. We can do this by adding the maven source plugin to our pom file as shown below.</p>

{% highlight xml %}
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-source-plugin</artifactId>
	<version>2.1.2</version>
	<executions>
		<execution>
			<id>attach-sources</id>
			<goals>
				<goal>jar</goal>
			</goals>
		</execution>
	</executions>
</plugin>
{% endhighlight %}
&nbsp;


<h3>Deploying to Nexus</h3>

<p style="text-align: justify;">

To ensure our last two requirements of breaking the build for incompatible changes but not requiring everyone to build locally we need to deploy our code to the nexus repository. To do this we will create a settings.xml with the data shown below and run <strong>mvn clean install --settings ./settings.xml</strong>.</p>

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0" 
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0 http://maven.apache.org/xsd/settings-1.0.0.xsd">

<servers>
    <server>
      <id>myNexusRepo</id>
      <username>admin</username>
      <password>admin123</password>
    </server>
</servers>
</settings>
{% endhighlight %}
&nbsp;



<h3>Pulling from nexus</h3>

<p style="text-align: justify;">
Now we can just setup a maven project to pull in the generated code by adding the dependency shown below. This fulfills our last two requirements, if there is an incompatible change it will break the build for the dependent project without requiring people to build proto files themselves.  </p>

{% highlight xml %}
<dependency>
    <groupId>com.flybynight.protobuff</groupId>
    <artifactId>protocompiler</artifactId>
    <version>1.0-SNAPSHOT</version>
</dependency>

{% endhighlight %}




