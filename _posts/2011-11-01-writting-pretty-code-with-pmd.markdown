--- 
layout: post
title: Writing pretty code with PMD
wordpress_id: 541
wordpress_url: http://www.techtraits.ca/?p=541
date: 2011-11-01 00:16:39 +00:00
author: usman
categories: 
- Programming
tags:
- iPhone SDK
- code
- PMD
---
I recently found myself in the role of lead developer in my team and had to manage the work of several other junior developers. This is has been an interesting and rewarding experience and has taught me a lot about my self as a person and as a developer. I will leave the personal epiphanies for another time but as a developer I found that I have a lot of pet peeves about what code looks like and I want my juniors to cater to them. For example else must be written ...} else {... In addition some random preferences for code layout standards there are some genuine bugs that junior devs (who am I kidding, I am as bad as they are) leave in when writing code which are easily detectable and using a cursory review. That is were <a href="http://pmd.sourceforge.net/" title="PMD">PMD</a> comes in, with PMD you can force every one to following coding conventions otherwise fail the build. PMD comes with a nifty set of predefined rules and you can also easily add your own using <a href="http://www.w3schools.com/xpath/" title="xPath" target="_blank">xPath</a>.

<!--more-->

<p style="text-align: justify;">

Don't ask me what PMD stands for, I have tried in vain to find that out using extensive googleing. <a href="http://pmd.sourceforge.net/meaning.html" title="What does PMD Mean" target="_blank">Here</a> is a list of possible answers. What it does is allow you to add a build phase to your project which checks your code against a predefined set of rules and generates a report on violations. Many tools (<a href="http://jenkins-ci.org/" title="Jenkins" target="_blank">Jenkins</a>, <a href="http://www.sonarsource.org/" title="Sonar" target="_blank">Sonar</a> etc) will integrate directly with PMD and provide UI to browse code easily. I will go into the tools in subsequent articles but for now a quick tutorial on how to integrate PMD with your build. </p>

<p style="text-align: justify;">
As a starting point I will use code I wrote to go along with an earlier article <a href="http://www.techtraits.ca/five-minute-guide-to-setting-up-a-java-webserver/" title="Setting up a webservice using Guice & Sitebricks" target="_blank">Setting up a webservice using Guice & Sitebricks</a>. The code is available <a href="http://www.techtraits.ca/wp-content/uploads/2011/06/helloworld.zip" title="Hello World">here</a>. This is Java project build using maven, but PMD integration is available with other build systems and languages. Download and extract the code and compile using <a href="http://maven.apache.org/ref/3.0/" title="Maven 3" target="_blank">Maven</a> just to ensure everything is hunky dory. </p> 

{% highlight bash %}

> cd ${WHEREEVER_YOU_EXTRACTED_IT}/helloworld
> mvn clean install

{% endhighlight %}
&nbsp;



Hopefully you see something like:

{% highlight bash %}
[INFO] Installing /Users/usman/Downloads/helloworld/pom.xml to /Users/usman/.m2/repository/com/flybynight/helloworld/helloworld/1.0-SNAPSHOT/helloworld-1.0-SNAPSHOT.pom
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 4.372s
[INFO] Finished at: Mon Oct 31 20:34:07 EDT 2011
[INFO] Final Memory: 11M/81M
[INFO] ------------------------------------------------------------------------
{% endhighlight %}
&nbsp;





<h3>Maven PMD plugin</h3>

<p style="text-align: justify;">

To integrate PMD with your maven build open the pom.xml file in the project root and look for the <plugins> tag. We will add the pmd plugin reference here. </p>



{% highlight xml %}
<plugin>
	<groupId>org.apache.maven.plugins</groupId>
	<artifactId>maven-pmd-plugin</artifactId>
	<version>2.5</version>
	<configuration>
		<targetJdk>1.6</targetJdk>
		<linkXref>false</linkXref>
		<failOnViolation>true</failOnViolation>
		<failurePriority>1</failurePriority>
		<rulesets>
			<ruleset>${pom.basedir}/pmd-rulesets.xml</ruleset>
		</rulesets>
	</configuration>
	<executions>
		<execution>
			<goals>
				<goal>check</goal>
			</goals>
		</execution>
	</executions>
</plugin> 
{% endhighlight %}
&nbsp;



<h3>Configuration</h3>

<p style="text-align: justify;">

Most of the parameters above are fairly self explanatory except linkXref which specifies whether our PMD report should have links to the cross referenced source code. The failOnViolation and  failurePriority are used to control when we fail the build. All PMD violations have a priority (as we will see later) ranging from 1-5 with 1 being the worst violations and 5 being the least heinous. In our configuration we are specifying that any violation should break the build (Using the <em>failOnViolation</em> tag) and that all warnings priority 1 (or higher if we had specified a lower number) should be considered violations (Using the <em>failurePriority</em> tag). All other priorities will result in a warning but will still allow the build to succeed. </p>



<h3>Rule sets</h3>

<p style="text-align: justify;">

In the configuration above we are specifying a rule sets file which contains all the rules which our code will be checked against. You can see a complete set of common rule sets here: <a href="http://pmd.sourceforge.net/rules/index.html" title="Rule Sets" target="_blank">Rule Sets</a> and the rule set definition I have used here <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/pmd-rulesets.xml_.txt'>pmd-rulesets.xml</a>. In addition the snippet below shows the format of the rule set file. Each <em>rule</em> element in the links to one of the predefined rules and assigns a priority to it. </p>



{% highlight xml %}
<?xml version="1.0"?>
<ruleset name="PMD-Rules">
	<description>
		Rule sets go here
	</description>
	<rule ref="rulesets/basic.xml/BooleanInstantiation">
		<priority>5</priority>
	</rule> 
	<rule ref="rulesets/basic.xml/CollapsibleIfStatements">
		<priority>5</priority>
	</rule> 
</ruleset>
{% endhighlight %}
&nbsp;



<h3>PMD in action</h3>

<p style="text-align: justify;">

Download this rule set file (<a href='http://www.techtraits.ca/wp-content/uploads/2011/11/pmd-rulesets.xml_.txt'>pmd-rulesets.xml</a>) and add it to your project base directory. (Note you will have to rename and remove the .txt) Now recompile the project using mvn clean install and you should get the following log output. </p>

{% highlight bash %}
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time: 4.368s
[INFO] Finished at: Mon Oct 31 21:14:53 EDT 2011
[INFO] Final Memory: 15M/81M
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-pmd-plugin:2.5:check (default) on project helloworld: You have 1 PMD violation. For more details see:/XXXXXXXXXX/helloworld/target/pmd.xml -> [Help 1]
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">
Open up the pmd.xml file to see the PMD report; Luckily we only have one violation where we forgot to remove an unused import. As you can see the report reports the file and the line number where the violation is found. </p>

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<pmd version="4.2.5" timestamp="2011-10-31T21:14:52.771">
<file name="/Users/usman/Downloads/helloworld/src/main/java/com/flybynight/helloworld/GuiceCreator.java">
<violation beginline="7" endline="7" begincolumn="1" endcolumn="47" rule="UnusedImports" ruleset="Import Statement Rules" package="com.flybynight.helloworld" externalInfoUrl="http://pmd.sourceforge.net/rules/imports.html#UnusedImports" priority="1">
Avoid unused imports such as 'com.google.inject.servlet.ServletModule'
</violation>
</file>
</pmd>
{% endhighlight %}
&nbsp;

<h3>Source Code</h3>

* <a href="http://www.techtraits.ca/wp-content/uploads/2011/06/helloworld.zip" title="Initial Code" target="_blank">Initial Code</a>
* <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/helloworld.zip'>PMD Integrated Project</a>





<h3>External Links</h3>

<p style="text-align: justify;">

	<li><a href="http://pmd.sourceforge.net/" title="PMD">http://pmd.sourceforge.net/</a></li>

	<li><a href="http://www.w3schools.com/xpath/" title="XPath">http://www.w3schools.com/xpath/</a></li>

	<li><a href="http://jenkins-ci.org/" title="Jenkins" target="_blank">http://jenkins-ci.org/</a></li>

	<li><a href="http://www.sonarsource.org/" title="Sonar" target="_blank">http://www.sonarsource.org/</a></li>

	<li><a href="http://pmd.sourceforge.net/rules/index.htm" title="Rule Sets" target="_blank">http://pmd.sourceforge.net/rules/index.htm</a></li>









