--- 
layout: post
title: Custom PMD Rule for Private Injected fields
wordpress_id: 700
wordpress_url: http://www.techtraits.ca/?p=700
date: 2011-12-04 23:51:05 +00:00
---
<p style="text-align: justify;">
In my current project I am making extensive use of dependency injection using <a href="http://code.google.com/p/google-guice/" title="Guice" target="_blank">Guice</a>. More specifically I am using member injection to inject objects into the member variables of a class. In java member variables should usually be private, but this is even more important when using injection as the whole purpose of injecting members is to remove explicit dependencies and make code more modular. However, try as I might I cannot remember to change all my protected injected variables to private. Therefore I ended up just creating a PMD rule to the same effect. 
<!--more-->

<pre lang="xml">
	<rule name="PrivateInjections" message="Please make injected fields private"
		class="net.sourceforge.pmd.rules.XPathRule">
		<description>We don't take kindly to non private injected fields round
			these parts
		</description>
		<priority>1</priority>
		<properties>
			<property name="xpath">
				<value>
          <![CDATA[//ClassOrInterfaceBodyDeclaration[contains(Annotation//Name/@Image,'Inject') and contains(FieldDeclaration/@Private,'false')]]]>
				</value>
			</property>
		</properties>
		<example>
                    <![CDATA[
                       	@Inject
                       	public String myParameter; //is bad

                      	public String myParameter; //is better

                       	@Inject
                       	private String myParameter; //is best



                    ]]>
		</example>
	</rule>
</pre>
