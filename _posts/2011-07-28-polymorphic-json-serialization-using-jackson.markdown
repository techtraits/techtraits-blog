--- 
layout: post
title: Polymorphic JSON Serialization using Jackson
wordpress_id: 217
wordpress_url: http://www.techtraits.ca/?p=217
author: usman
date: 2011-07-28 03:32:28 +00:00
categories: 
- Programming
tags:
- Java
- code
- Jackson
- JSON
---
<p style="text-align: justify;">JSON is a lightweight language independent data-interchange format which is one of the common ways of encoding data over HTTP. This articles goes over the use of the <a href="http://jackson.codehaus.org/">Jackson</a> library to serialize and deserialize Java object to JSON.</p>

<!--more-->

<h3>Project Setup</h3>

<p style="text-align: justify;">

If you have not already done so download and install a latest copy of the <a href="http://www.oracle.com/technetwork/java/javase/downloads/index.html">JDK</a>. Also download the latest <a href="http://jackson.codehaus.org/1.8.4/jackson-all-1.8.4.jar">Jackson Jar</a> file. Create a folder with the jar file, and a few classes you want to serialize. I created ParentClass.java, Child1.java and Child 2.java.</p>

<h3>Parent.java</h3>

<p style="text-align: justify;">The excerpt below shows the contents of Parent.java, note that we are annotating the class to help with serialization. The "JsonTypeInfo" annotation tells jackson to encode the object type in the resulting JSON output in a field called objectType. Further we are also defining the possible subtypes of Parent which any input JSON text could be serialized.</p>


{% highlight java %}
import org.codehaus.jackson.annotate.JsonSubTypes;
import org.codehaus.jackson.annotate.JsonTypeInfo;

@JsonTypeInfo(use=JsonTypeInfo.Id.NAME, include=JsonTypeInfo.As.PROPERTY, property="objectType")
@JsonSubTypes({

        @JsonSubTypes.Type(value=Child1.class),
        @JsonSubTypes.Type(value=Child2.class)
})
public class ParentClass {

}
{% endhighlight %}
&nbsp;
<h3>Child1.java</h3>

<p style="text-align: justify;">The next snippet shows the Child1 class, we have also annotated the class to encode type but we do not need to define any sub-types. The class has two fields, one of which is annotated to be a JsonProperty and the other is marked to be ignored.</p>


{% highlight java %}
import org.codehaus.jackson.annotate.JsonTypeInfo;
import org.codehaus.jackson.annotate.JsonProperty;
import org.codehaus.jackson.annotate.JsonIgnore;

@JsonTypeInfo(use=JsonTypeInfo.Id.NAME, include=JsonTypeInfo.As.PROPERTY, property="objectType")
public class Child1 extends ParentClass {

	@JsonProperty
	public int SerializeMe;

	@JsonIgnore
	public int dontSerialize me;

}
{% endhighlight %}
&nbsp;
<h3>Child2.java</h3>

<p style="text-align: justify;">

Child2 is very similar except for a few differences which highlight some of the features of Jackson, first we are able serialize more complex types such as the ArrayList of type string and second, we are also able to annotate Java Bean style getters to return a JSON property even if they have no member variable to back them.</p>

{% highlight java %}
import org.codehaus.jackson.annotate.JsonProperty;
import org.codehaus.jackson.annotate.JsonTypeInfo;
import java.util.List;

@JsonTypeInfo(use=JsonTypeInfo.Id.NAME, include=JsonTypeInfo.As.PROPERTY, property="objectType")

public class Child2 extends ParentClass {

	@JsonProperty
	public List SerializeMe;

	@JsonProperty
	public int getSerializeMeToo() {
		return 53;
	}

	@JsonProperty
	public void setSerializeMeToo(int value) {
		//Do nothing
	}
}{% endhighlight %}
&nbsp;
<h3>Driver.java</h3>

<p style="text-align: justify;">

Finally lets create a driver class to test our serialization and deserialization. For this we use the <strong>ObjectMapper</strong> class which has a <strong>writeValueAsString</strong> method. We just pass an annotated class to ObjectMapper's writeValueAsString method and get an encoded JSON string. Similarly we can use the <strong>readValue</strong> method to deserialize JSON back to a java object. As the code below shows we pass the string representation of JSON as well as an Ancestor of the object we are deserializing. Notice how we pass <strong>ParentClass</strong> to the readValue method but when print the clss type out you will see it outputs "Child1" and "Child2" correctly.</p>

{% highlight java %}
import org.codehaus.jackson.map.ObjectMapper;
import java.util.Arrays;

public class Driver {

	public static void main(String[] args) {

		try {

			ObjectMapper oMapper = new ObjectMapper();
			Child1 child1 = new Child1();
			child1.SerializeMe = 10;
			child1.dontSerializeMe = 12;
			Child2 child2 = new Child2();
			child2.SerializeMe = Arrays.asList("1","2","3");
			String outputChild1 = oMapper.writeValueAsString(child1);
			String outputChild2 = oMapper.writeValueAsString(child2);
			System.out.println(outputChild1);
			System.out.println(outputChild2);

			ParentClass inputChild1 = oMapper.readValue(outputChild1, ParentClass.class);
			ParentClass inputChild2 = oMapper.readValue(outputChild2, ParentClass.class);

			System.out.println(inputChild1.getClass().toString());
			System.out.println(inputChild2.getClass().toString());

		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}

}{% endhighlight %}
&nbsp;

<h3>Compiling and running the code</h3>



{% highlight bash %}
#To compile the code fireup a terminal or the command line and enter the following command
javac -classpath jackson-all-1.8.4.jar:./ *.java

#To run the code run the following command:
java -classpath jackson-all-1.8.4.jar:./ Driver

#Your output should be something like:
{"objectType":"Child1","SerializeMe":10}

{"objectType":"Child2","SerializeMe":["1","2","3"],"serializeMeToo":53}

class Child1

class Child2

{% endhighlight %}
&nbsp;

<p style="text-align: justify;">

Notice the fact that the class name is added as a property to the output JSON, and how the dontSerializeMe feild of Child1 is ignored. Also note that the types of the objects generated from JSON are Child1 and Child2 respectively even though we told the mapper we were looking for a <strong>ParentClass</strong> type.</p>

<h3>Source Code</h3>

<p style="text-align: justify;">

The source code shown here can be <a href="http://www.techtraits.ca/wp-content/uploads/2011/07/jackson_serialization.zip">Downloaded Here</a>

Note that all code and other source provided here are licensed under the BSD License available <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/Licensing.txt'>Here</a>. </p>



<h3>Further Reading</h3>

* [JSON](http://www.json.org/)
* [Jackson](http://jackson.codehaus.org/Download)
* [Jackson Tutorials](http://jackson.codehaus.org/Tutorial)


