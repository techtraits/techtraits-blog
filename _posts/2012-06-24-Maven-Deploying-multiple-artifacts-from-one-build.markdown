--- 
layout: post
title: Maven:Deploying multiple artifacts from one build
date: 2012-06-24 09:43:03
author: usman
categories: 
- Build Management
- Maven
tags:
- maven
- sonatype
- nexus

---

For a recent project I had to deploy a self-executing jar to the nexus repository as well as the standard jar and I wanted to make this process as stream lined as possible. I used the assembly plugin (Details) to create the jar but the default deploy plugin would not upload this artifact to sonatype. While I could do this manually I wanted to make this a default part of the deploy goal. To do this we need to add an extra deploy plugin invocation in our pom.

To add the invocation to the deploy plugin just add the maven-deploy-plugin tag to the plugins section in your pom. We will be adding one execution (See line 4) and hooking it to the deploy phase (See line 6). By hooking it to the deploy phase we will make sure the maven deploy goal also runs this execution.

We will be using the deploy-file goal of the plugin and will specify the ArtifactID, GroupID, Packaging, Version and Classifier of the deployed artifact. This is important as it controls where your artifact will uploaded too in the repositories file system. Packaging is important too as it will change the extension of the uploaded file according to packaging.

We specify the file to be uploaded (See line 16-18), the deploy phase runs after the compile so we can assume all generated files are present. We need to specify the pom file for this artifact in case this artifact needs to be used as a dependency by downstream packages. I am using the same pom file as the main artifact however you can upload a replacement pom file if needed. Be careful as this will overwrite the original pom file. Lastly we need to specify the repository URL, unfortunately the plugin will not pull in the URL from the Distribution Management tag in the pom. 

{% highlight xml %}
<plugin>
	<artifactId>maven-deploy-plugin</artifactId>
	<executions>
		<execution>
			<id>executable pom</id>
			<phase>deploy</phase>
			<goals>
				<goal>deploy-file</goal>
			</goals>
			<configuration>
				<artifactId>myProject</artifactId>
				<packaging>jar</packaging>
				<version>${project.version}</version>
				<groupId>com.something.somethingelse</groupId>
				<classifier>bin</classifier>
				<file>
					target/myProject-${project.version}-exe.jar
				</file>
				<pomFile>
					pom.xml
				</pomFile>
				<url>
					http://myreporurl:8080/nexus/content/repositories/reponame/
				</url>
			</configuration>
		</execution>
	</executions>
</plugin>
{% endhighlight %}
&nbsp;

And that’s it, now when you run mvn deploy this additional file will be deployed to your nexus repository in addition the default jar.