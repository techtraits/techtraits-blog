--- 
layout: post
title: Regular Expressions in Eclipse Find
wordpress_id: 761
wordpress_url: http://www.techtraits.com/?p=761
date: 2012-01-17 17:43:13 +00:00
author: usman
categories: 
- Software Management
tags:
- Maven
- Nexus
- Sonatype
---


<p style="text-align: justify;">This one is from the D'oh category, How many times have you realized you made a simple mistake in many many places. Sometimes a simple find and replace would suffice but often the matches are ever so slightly different. For example, in one of my projects we had code that had the following code and replacement (Obfuscated). Unfortunately foo and bar could be lots of different values so search and replace was useless. This is where regex replacement comes to the rescue.  <!--more--> Hit Ctrl + F to pull up the find menu and hit the Regular Expression check box shown. </p>

![eclipsefind](/assets/images/eclipsefind.png)

{% highlight xml %}
    //Initial 
    ...
    foo.doSomething(bar, getData(bar));
    ...

    //Replacement
    ...
    foo.doSomething(bar, getOtherData(bar), getData(bar));
    ...
{% endhighlight %}
&nbsp;


<h3>Finding the matches</h3>

{% highlight perl %}

[a-z][A-zA-Z]*[.]doSomething\([a-z][A-zA-Z]*, getData\([a-z][A-zA-Z]*\)\)
{% endhighlight %}
&nbsp;





<p style="text-align: justify;"> There are lots of nice tutorials on regular expressions (<a title="Regular Expressions Tutorial" href="http://docs.oracle.com/javase/tutorial/essential/regex/index.html" target="_blank">such as this one</a>) so I will not go into them here. However, I will write down the expression that you may use to find the target string above. A quick run through; we are looking for a variable in camel case so a single lower case letter followed by one or more Uppercase or lower case letters and a period. then we match the doSomething literal string and an opening brace. Note that we have had to escape the brace. The we have the same definition of a variable name followed by a comma, the getData literal and another variable name. Lastly we close of the braces. This will match the line "foo.doSomething(bar, getData(bar))" where foo and bar can be any variable name</p>



<h3>Defining the Replacement</h3>

<p style="text-align: justify;">

To define the replacement we must capture foo and bar. This can be done by using round braces around any part of the regular expression. So our search string now becomes the string shown below. The difference is subtle, notice the extra round braces at <font color="green"><strong>(</strong></font>[a-z][A-zA-Z]*<font color="green"><strong>)</strong></font> and doSomething\(<font color="green"><strong>(</strong></font>[a-z][A-zA-Z]*<font color="green"><strong>)</strong></font>. Anything inside the braces gets captures as a string for placing into the replacements string. The captured strings a re numbered from left to right and can be placed into replacement as <font color="green"><strong>$1, $2</strong></font> and so on. The replace text using these variables is shown below.



{% highlight perl %}

//Find:
([a-z][A-zA-Z]*)[.]doSomething\(([a-z][A-zA-Z]*), getData\([a-z][A-zA-Z]*\)\)

//Replace with:
$1.doSomething\($2, getOtherData\($2\),getData\($2\)\)

{% endhighlight %}

