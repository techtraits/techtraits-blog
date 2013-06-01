--- 
layout: post
title: Implementing Jackson Views
wordpress_id: 231
wordpress_url: http://www.techtraits.ca/?p=231
authors: 
- usman
date: 2011-08-12 19:42:53 +00:00
categories: 
- Programming
tags:
- Java
- code
- Jackson
- JSON
---
<p style="text-align: justify;">My previous <a href="/Programming/2011/07/27/polymorphic-json-serialization-using-jackson">tutorial</a> detailed how to use the Jackson library to automatically serialize to and from JSON. However, what if you want to serialize objects differently based on the context. For example, you may want to store some internal state about the object in a data store but not want to report that state to the client. So when you serialize for client you would skip some parameters, wouldn't it be great if there was an easy way to do this using Jackson? Well there is, Views.</p>

I am going to use the code we wrote in my last tutorial as a starting point so if you have not already done so go grab that code and go through the tutorial quickly.

<!--more-->

<h3>Defining the views</h3>

<p style="text-align: justify;">Jackson uses classes to mark views so lets create a class called "JacksonViews" to contain all our views. The class will have a member variable of type class for each view we want to implement. Lets create a default view and an internal view and a client view. The code will look something like this:</p>


{% highlight java %}
public class JacksonViews {
	public static class ClientView extends DefaultView {}
	public static class InternalView extends DefaultView {}
	public static class DefaultView {}
}
{% endhighlight %}
&nbsp;

<h3>Updating annotations for view</h3>

<p style="text-align: justify;">Open up Child1.java and look for the SerializeMe parameter. In the previous tutorial we had only two types of parameters; Json Properties and ignored parameters. For this tutorial we will replace the SerializeMe with three parameters: SerializeMeAlways, SerializeMeClient and SerializeMeInternal. The SerializeMeAlways parameter will be given the additional annotation JacksonView with the "JacksonViews.DefaultView". Similarly the other two properties will be annotated with the JacksonView annotation with values "JacksonViews.ClientView" and "JacksonViews.InternalView" respectively. The code should now something like this.</p>


{% highlight java %}

import org.codehaus.jackson.annotate.JsonTypeInfo;
import org.codehaus.jackson.annotate.JsonProperty;
import org.codehaus.jackson.annotate.JsonIgnore;

@JsonTypeInfo(use=JsonTypeInfo.Id.NAME, include=JsonTypeInfo.As.PROPERTY, property="objectType")
public class Child1 extends ParentClass {

    @JsonView(JacksonViews.DefaultView.class)
	@JsonProperty
	public int SerializeMeAlways;

    @JsonView(JacksonViews.InternalView.class)
    @JsonProperty
    public int SerializeMeInternal;

    @JsonView(JacksonViews.ClientView.class)
    @JsonProperty
	public int SerializeMeClient;

	@JsonIgnore
	public int DontSerializeMe;
}
{% endhighlight %}
&nbsp;

<h3>Serializing using view</h3>

<p style="text-align: justify;">Finally lets open up the the Driver.java file and update the code to see how the views work. We can create an instance of Child1 and set values for all the parameters we specified. We then use the "setSerializationConfig" method of the object mapper to add views to the mapper. In the code below we are first adding the client view then the internal view.</p>


{% highlight java %}
import org.codehaus.jackson.map.ObjectMapper;
import java.util.Arrays;

public class Driver {

	public static void main(String[] args) {

		try {
			ObjectMapper oMapper = new ObjectMapper();
			Child1 child1 = new Child1();
			child1.SerializeMeAlways = 1;
			child1.SerializeMeClient = 1;
			child1.SerializeMeInternal = 1;
			child1.DontSerializeMe = 12;

			oMapper.setSerializationConfig(oMapper.getSerializationConfig()
					.withView(JacksonViews.ClientView.class));
			printChild(child1,oMapper); 

			oMapper.setSerializationConfig(oMapper.getSerializationConfig()
					.withView(JacksonViews.InternalView.class));
			printChild(child1,oMapper); 
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

	public static void printChild(Child1 child1, ObjectMapper oMapper) throws Exception{
		String outputChild1 = oMapper.writeValueAsString(child1);
		System.out.println(outputChild1);
		ParentClass inputChild1 = oMapper.readValue(outputChild1, ParentClass.class);
		System.out.println(inputChild1.getClass().toString());
	}
}
{% endhighlight %}
&nbsp;


<h3>Compiling and running the code</h3>

{% highlight bash %}
# To compile the code fire up a terminal or the command line and enter the following command,
javac -classpath jackson-all-1.8.4.jar:./ *.java

# To run the code run the following command:

java -classpath jackson-all-1.8.4.jar:./ Driver
{% endhighlight %}
&nbsp;

Your output should be something like:
{% highlight bash %}
{"objectType":"Child1","SerializeMeAlways":1,"SerializeMeClient":1}

class Child1

{"objectType":"Child1","SerializeMeAlways":1,"SerializeMeInternal":1}

class Child1
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">Notice that the first time we output the object using the client view jackson writes the SerializeMeClient parameter but not the SerializeMeInternal parameter. Similarly, when we use the internal view the SerializeMeInternal is present but the SerializeMeClient is not. The SerializeMeAlways parameter is as the name suggests is always present.</p>



<h3>Source Code</h3>

The source code shown here can be downloaded [Here](https://github.com/techtraits/jackson-views-example/tree/master/jackson_views)

Note that all code and other source provided here are licensed under the [BSD License](/assets/Licensing.txt). 


