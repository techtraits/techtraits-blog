--- 
layout: post
title: Jackson Optimization, Using Non-Default for fun and profit
wordpress_id: 978
wordpress_url: http://www.techtraits.com/?p=978
date: 2012-03-10 16:12:25 +00:00
author: usman
categories: 
- Programming
tags:
- Java
- code
- Jackson
- JSON

---
<p style="text-align: justify;">

We use Jackson JSON processor extensively for serializing/deserializing  objects to for storage in backing storage service as well as to send responses between client and server. One thing we noted was that despite our best efforts a lot of objects had fields that we were either null or set to default values. For example our We store all the virtual goods owned by a user. For a lot of new users this list is empty as the have not bought anything yet. However we still incur the overhead of sending and storing an empty list. This translates to both a performance cost and dollar cost as we use Amazon Ec2 which charges us for bandwith and and DynamoDB which charges us for read/write capacity used. Luckily we can use a nice little feature of jackson called Non-Default get around this issue. 
</p>


<!--more-->



<p style="text-align: justify;">

The first step is to tell jackson to only include non null objects in serialization output. This will take care of most java objects which are uninitialized. 

</p>


{% highlight java %}
ObjectMapper mapper = new ObjectMapper();
mapper.getSerializationConfig().
setSerializationInclusion(JsonSerialize.Inclusion.NON_NULL);
{% endhighlight %}
&nbsp;
<p style="text-align: justify;">

A lot of times you do not want to leave so many null objects floating around in your code. For example its a good idea to initialize all lists to empty lists rather than letting them be nulls. In this scenario we set the Non-Default inclusion of the serialization config and then initialize objects to a default value. Not we must initialize the parameters in static context rather then the constructor. 
</p>


{% highlight java %}

ObjectMapper mapper = new ObjectMapper();

mapper.getSerializationConfig().
setSerializationInclusion(JsonSerialize.Inclusion.NON_NULL);

mapper.getSerializationConfig().
setSerializationInclusion(JsonSerialize.Inclusion.NON_DEFAULT);

{% endhighlight %}
&nbsp;

<h3>Quick Example</h3>


{% highlight java %}
public class SerializeMe {

	@JsonProeprty
	private int anInteger = 10;

	@JsonProeprty
	private List<String> lotsOfStrings = new ArrayList<String>();

	//Other Properties
}
{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

Say you have an object of the class above with the anInteger and lotsOfStrings properties not edited after object creation. When you serialize this object for storage to a database without the two optimizations shown above the object will serialize too: 
</p>


{% highlight json %}

{
    "anInteger": 10,
    "lotsOfStrings": [],
    "Other properties":""
}

{% endhighlight %}
&nbsp;


<p style="text-align: justify;">

Where as with the optimizations it will be much shorted saving you appriximately 40 bytes for each object instance. This may seem small but with millions of objects and objects with more properties this change can be significant.

This example also highlights one of the possible problems of the optimization, say that you use the same mapper for serializing objects which are reported to clients. Unless the client is aware of the default values it will not know what the value of anInteger is. For this reason its almost always better to use a different mapper for internal object serialization and client side serialization. </p>



<h3>External Links</h3>

* <a href="http://jackson.codehaus.org/" title="Jackson" target="_blank">Jackson JSON Processor</a>




