--- 
layout: post
title: Custom PMD Rules using XPath
wordpress_id: 568
wordpress_url: http://www.techtraits.ca/?p=568
date: 2011-11-05 21:33:52 +00:00
author: usman
categories: 
- Programming
tags:
- debugging
- PMD
- XPath
---
<p style="text-align: justify;">As a follow-up to my earlier tutorial <a title="Writing pretty code with PMD" href="http://www.techtraits.ca/writing-pretty-code-with-pmd/" target="_blank">Writing pretty code with PMD</a> I am going to be discussing making custom PMD rules using <a title="XPath" href="http://www.w3schools.com/xpath/" target="_blank">XPath</a>. The first thing to note is that we use a <a title="Declarative Programming" href="http://en.wikipedia.org/wiki/Declarative_programming" target="_blank">declarative programming</a> paradigm to define our rules. We define or 'declare' what constitutes a PMD violation, but not what should be done about it, PMD takes care of that part.</p>

<!--more-->

<h3>Abstract Syntax Tree</h3>

<p style="text-align: justify;">PMD uses <a title="Abstract Syntax Tree" href="http://www.eclipse.org/articles/article.php?file=Article-JavaCodeManipulation_AST/index.html" target="_blank">Java Abstract Syntax Tree (AST)</a> representation of your source code to apply rules. Essentially the AST is representation of a java class with generic descriptors to refer each element in the source code. In code you may have a class called MyClass but in the AST its just a "ClassOrInterfacedeclaration". Each element which is contained within an other is its descendant in the tree. For example a field is defined inside a class declaration so it is a descendant of the class description. Similarly all items defined within the same element are siblings in the tree. Any information that can be used to differentiate an instance of the generic type (such as the data type of the field) is stored as a property of the element. If the description above sounds reminiscent of XML its because ASTs are basically XML documents. As basic example of AST representation see the following code and its AST representation.</p>



{% highlight java %}
public class MyClass {

	int x;
	float y;
}
{% endhighlight %}
&nbsp;


<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-05-at-8.01.20-PM.png"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-05-at-8.01.20-PM.png" alt="" title="AST Reprsentation of Class" width="317" height="300" class="size-full wp-image-585" /></a>


<h3>PMD Rule Designer</h3>

<p style="text-align: justify;">

Before we start defining our rules we need a sandbox in which to quickly test our code. Luckily for use PMD comes with just such a tool, PMD Rule designer. I have repackaged the tool into a single executable jar file which you can download here (<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/PMDDesigner.jar" title="PMDRule designer" target="_blank">PMDRuleDesigner.jar</a>). To run the tool just type java -jar java -jar PMDDesigner.jar into the *nix terminal or windows command line. Write your code in the top left section and hit the "Go" button. The bottom right section will list the AST representation of your code. The two sections on the right deal with XPath, which we will be discussing next. </p>



<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/pmddesigner.png"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-05-at-7.54.28-PM-1024x499.png" alt="" title="PMD Rule Designer" width="640" height="311" class="size-large wp-image-583" /></a>



<h3>XPath Syntax</h3>

<p style="text-align: justify;">

<h4>"/" Has child</h4> 

<p style="text-align: justify;">

The forward slash defines a child query, For example <font color="green">/TypeDeclaration</font> defines that we want to match a child of the root node which is of type "TypeDeclaration". We can also use multiple slashes in a query to search for a set of child relation ships. For example the query below will match will both field declarations in the code above. </p>

{% highlight xml %}
/TypeDeclaration/ClassOrInterfaceDeclaration/ClassOrInterfaceBody/ClassOrInterfaceBodyDeclaration/FieldDeclaration
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">
Enter the query specified above into the top left box of the PMD Rule Designer and hit go. In the box in the bottom right you should see the line (Line 4 & Line 5) numbers of the two field declarations. </p>

<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/singleslashquery"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-06-at-1.44.09-AM-1024x301.png" alt="" title="Single Slash Query" width="640" height="188" class="aligncenter size-large wp-image-590" /></a>

<h4>"//" Has Descendant</h4>

<p style="text-align: justify;">

You don't always want to define the full path from root for the element you are searching for so instead of using the has child relation ship you can use the double forward slash or has dependent relationship. This will search for any descendant of the current node. There for the query above to search for field definitions could also be written as <font color="green">//FieldDeclaration</font>.

</p>

<p style="text-align: justify;">

The has descendant is not only useful for shortening queries it is also useful for searching for specific cases regardless of where they exist in the source tree. For example, if we take the code below. There is no query using child relationships alone that will match both variable declarations (int x and float y). Where as the <font color="green">//PrimativeType</font>  query matches both. </p>

{% highlight java %}
class MyClass {

	int x;
	void method() {
		float y;
	}
}
{% endhighlight %}
&nbsp;


<h4>"@" Has Property</h4>

<p style="text-align: justify;">

The @ sign is used to denote has property, and we can use properties to get information about specific instances of elements. For example the <font color="green">Image</font> property stores the name of the element (I have no idea why its stored in the Image property). So this query <font color="green">//VariableDeclaratorId/@Image</font> will return two values x and y. </p>

<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/properties.png"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-06-at-1.10.36-AM.png" alt="" title="Proprties" width="797" height="338" class="size-full wp-image-596" /></a>



<h4>"*" Wild Card</h4> 

<p style="text-align: justify;">

Wild cards are useful for matching many similar elements for example if we wanted to find all the fields and method declarations in a class. for fields we would use a query such as <font color="green">//ClassOrInterfaceBodyDeclaration/FieldDeclaration</font> where as for a method declaration it would be something like <font color="green">//ClassOrInterfaceBodyDeclaration/MethodDeclaration</font>. Using a wild card we can define the query as <font color="green">//ClassOrInterfaceBodyDeclaration/*</font></p>

{% highlight java %}
class MyClass {

	int x;
	void method() {
		float y;
	}
}
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

We can also use wild cards to list all properties of an element by combining @ and * e.g. <font color="green">//ClassOrInterfaceBodyDeclaration/FieldDeclaration/@*</font></p>



<h4>"[]" Predicates</h4> 

<p style="text-align: justify;">

Conditionals are used to filter the set of possible nodes that match certain portions of the XPath string. For example if in the code below we wish to single out the function(s) which return an int we would use the XPath <font color="green">//MethodDeclaration/ResultType[contains(Type/*/@Image, "int")]</font>. The first part defines a tree (or sub-tree) to which the conditional applies. In the example we would only apply the condition to the ResultType nodes which are children of a MethodDeclaration node. In the conditional we specify that the node must have a child or type 'Type' which in turn has an Image property containing the value 'int'. Note how we use the wildcard to avoid having to specify whether the function will return PrimitiveType or ReferenceType. </p>

{% highlight java %}
class MyClass {
	int func2() {
		return 0;
	}	

	void func2() {
	}
}
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

By changing the query slightly we can even find the name of the function(s) with the int return type. Note we are now conditionally selecting a MethodDeclaration node which matches the given criterion. Once we have the node we look for its MethodDeclarator child and retrieve the method name. </p>

{% highlight xml %}
	//MethodDeclaration[contains(ResultType/Type/*/@Image, "int")]/MethodDeclarator/@Image
{% endhighlight %}
&nbsp;



<p style="text-align: justify;">

We use the contains functions for our query but there are many other function you can use for predicates. An exhaustive list can be found <a href="http://www.w3schools.com/xpath/xpath_functions.asp#string" title="String Functions" target="_blank">here</a></p>



<h3>My first rule</h3>

<p style="text-align: justify;">

Ok enough beating around the bush lets create our first PMD rule. This is one of my pet peeves, I hate unused or overly generic imports such as <font color="green">import java.NET.*;</font> that all newbies to java seem to use. So how can we stop them? First of all fire up your pmd rule designer and write some imports to see what they look like, I like to write one example of a violation and one example of proper usage so that I can see the differences. If you look at the properties of the two statements you will see that if we use the wild card import the PackageName property matches the ImportedName property. With the query <font color="green">/ImportDeclaration[@PackageName=@ImportedName]</font> we can select all the imports which use the wild card matching and not the specific imports. Try this query in the Rule designer to verify that it only matches the wild card import. </p>



{% highlight java %}
import java.net.URL;
import java.net.*;
{% endhighlight %}
&nbsp;



<table border="0">

<tr>

<td>

<a href="http://www.techtraits.ca/custom-pmd-rules-using-xpath/wildimport"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-13-at-9.22.59-PM.png" alt="" title="Wild Card Import" width="300" height="168" class="size-full wp-image-614" /></a>

</td>

<td>

<a href="http://www.techtraits.ca/wp-content/uploads/2011/11/specificimport"><img src="http://www.techtraits.ca/wp-content/uploads/2011/11/Screen-Shot-2011-11-13-at-9.23.08-PM-300x168.png" alt="" title="Specific Import" width="300" height="168" class="size-medium wp-image-615" /></a>

</td>

</tr>

</table>



<p style="text-align: justify;">

Ok now that we have our XPath query lets create a rule set file, and add the custom rule definition. We give the rule a name, an admonishing message to be displayed to violators as well as a longer description. We can set how severe want the rule violation to be considered. As you can see I really hate wild card imports because I set it to highest level. The all important XPath rule goes in the property.value item of the property named xpath. </p>

{% highlight xml %}

    <rule name="DontImportWild" message="Please no wild card imports" class="net.sourceforge.pmd.rules.XPathRule">

    <description>We don't take kindly to imports such as java.net.* round these parts</description>
    <priority>1</priority>
    <properties>
      <property name="xpath">
        <value>
          <![CDATA[/ImportDeclaration[@PackageName=@ImportedName]]]>
        </value>
      </property>
    </properties>
    <example>
    <![CDATA[
    	import java.net.*; //is bad
    	import java.net.URL; //is better
    ]]>
    </example>
  </rule>
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

You can append this rule to the pmd ruleset in my earlier tutorial <a href="http://www.techtraits.ca/writting-pretty-code-with-pmd/" title="Writing pretty code with PMD" target="_blank">Writing pretty code with PMD</a> which can be downloaded <a href="http://www.techtraits.ca/wp-content/uploads/2011/11/helloworld.zip" title="PMD Project" target="_blank">here</a>. When you run the compile you will get the following output: </p>

{% highlight bash %}
[ERROR] Failed to execute goal org.apache.maven.plugins:maven-pmd-plugin:2.5:check (default) on project helloworld: You have 1 PMD violation. For more details see:helloworld/target/pmd.xml -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

And if you open said file you will see the following information, telling you that the problem is on line 8 of the GuiceCreator.java file and that we should not use wild card imports. </p>

{% highlight xml %}
<?xml version="1.0" encoding="UTF-8"?>
<pmd version="4.2.5" timestamp="2011-11-13T21:55:12.677">
<file name="helloworld/src/main/java/com/flybynight/helloworld/GuiceCreator.java">
<violation beginline="8" endline="8" begincolumn="1" endcolumn="18" rule="DontImportWild" ruleset="PMD-Rules" package="com.flybynight.helloworld" priority="1">
Please no wild card imports
</violation>
</file>
</pmd>
{% endhighlight %}
&nbsp;



<h3>Conclusion</h3>

<p style="text-align: justify;">

Despite the length of this article note that we were able to create a small xml snippet which will fix a coding malpractice through out all our code. Granted that this was a simple case but using XPath we can create more complex ad intricate rules. Further more if we spend the effort writing the rule(s) once we can ensure code quality without the overhead of code reviews as PMD can be integrated with our build. </p>



<h3>Source Code</h3>

<a href='http://www.techtraits.ca/wp-content/uploads/2011/11/custom_pm.zip'>Here</a> is the complete project with updated ruleset file and violation. Note that all code and other source provided here are licensed under the BSD License available <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/Licensing.txt'>Here</a>. 











<h3>External Links</h3>

<p style="text-align: justify;">



<ul>

	<li><a title="PMD" href="http://pmd.sourceforge.net/">http://pmd.sourceforge.net/</a></li>

	<li><a title="XPath" href="http://www.w3schools.com/xpath/">http://www.w3schools.com/xpath/</a></li>

	<li><a title="Jenkins" href="http://jenkins-ci.org/" target="_blank">http://jenkins-ci.org/</a></li>

	<li><a title="Sonar" href="http://www.sonarsource.org/" target="_blank">http://www.sonarsource.org/</a></li>

	<li><a title="Rule Sets" href="http://pmd.sourceforge.net/rules/index.htm" target="_blank">http://pmd.sourceforge.net/rules/index.htm</a></li>

	<li><a title="Abstract Syntax Tree" href="http://www.eclipse.org/articles/article.php?file=Article-JavaCodeManipulation_AST/index.html" target="_blank">http://www.eclipse.org/articles/article.php?file=Article-JavaCodeManipulation_AST/index.html</a></li>

	<li><a href="http://www.w3schools.com/xpath/xpath_functions.asp#string" title="String functions" target="_blank">http://www.w3schools.com/xpath/xpath_functions.asp#string</a></li>

	<li><a href="http://www.flickr.com/photos/fortinbras/588295779" title="" target="_blank">Photo Curtesy of Dan Iggers</a></li>





</ul>

&nbsp;
