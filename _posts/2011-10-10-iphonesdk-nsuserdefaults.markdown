--- 
layout: post
title: "iPhoneSDK: NSUserDefaults"
wordpress_id: 457
wordpress_url: http://www.techtraits.ca/?p=457
date: 2011-10-10 19:10:55 +00:00
authors: 
- usman
categories: 
- Programming
tags:
- iPhone SDK
- code
- iOS
- Objective C
- NSUserDefaults
---

<p style="text-align: justify;">
One of the common use case when writing an iPhone app is to store user preferences and other application settings such that they are globally accessible within your app and persistent across restarts. While you could use the persistence API for this purpose there is a much simpler solution using NSUserDefaults. NSUserDefaults provides you with access to a persistent global key value store. </p>

<!--more-->

<h3> Storing Objects</h3>
<p style="text-align: justify;">
To store an object create an instance of NSUserDefaults with the standardUserDefaults method and then use the setObject method to store your object against a key much as you would do in a NSMutableDictionary. Normally the properties are stored in memory and written to backing store periodically. To force a persistent storage update call the synchronize method.</p>


{% highlight objectivec %}
NSString* message = @"This is the message.";
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
[defaults setObject:message forKey:@"message"];
[defaults synchronize];
{% endhighlight %}
&nbsp;

<h3> Retrieving objects</h3>

<p style="text-align: justify;">
To retrieve an object from NSUserDefaults just create a instance much like before with and then call the <em>foo</em>ForKey method where foo can be any one of; array, bool, data, dictionary, float, integer, object, stringArray, string, double, URL. </p>

{% highlight objectivec %}
NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
NSString* message = [defaults stringForKey:@"message"];
{% endhighlight %}
&nbsp;


The last value set for each key will be retrieved across application restarts.  
