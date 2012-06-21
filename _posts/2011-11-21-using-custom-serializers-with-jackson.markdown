--- 
layout: post
title: Using Custom Serializers with Jackson
wordpress_id: 628
wordpress_url: http://www.techtraits.ca/?p=628
date: 2011-11-21 01:46:04 +00:00
author: usman
categories: 
- Programming
tags:
- Java
- code
- JSON
- Jackson
---
<p style="text-align: justify;">

<a href="http://jackson.codehaus.org/" title="Jackson" target="_blank">Jackson</a> is a powerful library which can automatically serialize to and from JSON to Java and I have made extensive use of it in my projects. To integration with jackson you annotate the fields within your <a href="http://en.wikipedia.org/wiki/Plain_Old_Java_Object" title="Plain_Old_Java_Object" target="_blank">POJOs</a> with the @JsonProperty annotation. Then using a JSON Mapper you can convert the POJOs to JSON and JSON to POJOs. For more details see my earlier article (<a href="http://www.techtraits.ca/polymorphic-json-serialization-using-jackson/" title="Polymorphic JSON Serialization using Jackson" target="_blank">Polymorphic JSON Serialization using Jackson</a>). However, sometimes the default behavior of the jackson mapper falls short. In one of my projects I needed to serialize a Java class to a specific integer field within that object. This is not possible using the default <a href="http://jackson.codehaus.org/1.9.0/javadoc/index.html" title="Object Mapper" target="_blank">ObjectMapper</a> or its <a href="http://jackson.codehaus.org/1.7.0/javadoc/org/codehaus/jackson/map/SerializationConfig.Feature.html" title="Serialization Config" target="_blank">serialization config</a>. This is where custom serializes come in using <a href="http://jackson.codehaus.org/1.2.1/javadoc/index.html?org/codehaus/jackson/map/annotate/JsonSerialize.html" title="JSONSerializer" target="_blank">Json Serializer</a> comes to the rescue. This article describes the use of custom serializers and deseralizers with the Jackson library.</p>

<!--more-->

<h3>Getting started</h3>

<p style="text-align: justify;">

As a starting point I will use the code in my earlier article <a href="http://www.techtraits.ca/polymorphic-json-serialization-using-jackson/" target="_blank">Polymorphic JSON Serialization using Jackson</a> which can be downloaded <a href="http://www.techtraits.ca/wp-content/uploads/2011/07/jackson_serialization.zip" title="Jackson Serialization" target="_blank">here</a>.</p>

<p style="text-align: justify;">

In the source files you downloaded open Child1.java, look for the SerializeMe property. It is annotated with the JSON Property and will there for be serialized to an integer. What if we wanted to write the string representation of the integer rather than a number. i.e. If the  field value was 3 we would write it as "three". The first step is to annotate the property with the <font color="green">@JsonSerialize</font> and <font color="green">@JsonDeserialize</font> annotations and provide the custom classes we want to use for serialization and deserialization as shown below. </p>  

{% highlight java %}
@JsonSerialize(using = CustomSerializer.class)
@JsonDeserialize(using = CustomDeSerializer.class)
@JsonProperty
public int SerializeMe;
{% endhighlight %}
&nbsp;



<h3>Implementing the Custom Serializer</h3>

<p style="text-align: justify;">

In order to implement a custom serializer we must extend the JsonSerializer class and define the template type to be the type for our annotated field. In our case the annotated field is on "int" type. Primitive types are automatically boxed into their respective object types, hence we will be using the Integer type. We override the serialize method which will receive the value of the field in the value parameter. Using the input value we can define what output we want to generate and then write it using the generator parameter. The generator class has many functions for writing the various Json types, we will be using the writeString method for our serializer however a complete list of methods is available <a href="http://jackson.codehaus.org/1.4.2/javadoc/org/codehaus/jackson/JsonGenerator.html" title="JsonGenerator" target="_blank">here</a>. I am writing a a small converter which generates the string value of input integers, see code below. </p>

{% highlight java %}

public class CustomSerializer extends JsonSerializer<Integer> {

	@Override
	public void serialize(Integer value, JsonGenerator generator, SerializerProvider provider) throws IOException,

			JsonProcessingException {



		if (value == 1) {

			generator.writeString("one");

		} else if (value == 2) {

			generator.writeString("two");

		} else if (value == 3) {

			generator.writeString("three");

		} else {

			generator.writeString("A big number");

		}

	}

}

{% endhighlight %}
</pre>nbsp;





<h3>Implementing the Custom Deserializer</h3>



<p style="text-align: justify;">

You can setup custom object deserialization in exactly the same fashion by extending the JsonDeserializer class and overriding the deserialize method. This method has a parser parameter which we can use to retrieve the Json data as shown below.</p>

</p>

{% highlight java %}

	@Override
	public Integer deserialize(JsonParser parser, DeserializationContext context) throws IOException,
			JsonProcessingException {

		String value = parser.getText();
		if (value.equals("one")) {
			return 1;
		} else if (value.equals("two")) {
			return 2;
		} else if (value.equals("three")) {
			return 3;
		} else {
			return 0;
		}
	}
{% endhighlight %}
&nbsp;



<h3>Testing the code</h3>

<p style="text-align: justify;">

Open up the Driver.java file from the downloaded sources and replace the main method with the code shown below. In this code we are creating and initializing an instance of the Child1 class and then writing it using a Jackson Object mapper. When you run this code you should see <font color="green">{"objectType":"Child1","SerializeMe":"three"}</font>. If you delete the annotations from the Child one class and rerun the code you should see <font color="green">{"objectType":"Child1","SerializeMe":3}</font>. When we deserialize we see that the value is again stored in the object as 3.  This simple and admittedly contrived example shows the power of custom serializers. I have used these in several projects to format responses according to client requirements without impacting server Object designs.</p>



{% highlight java %}
public static void main(String[] args) {
	try {
		ObjectMapper oMapper = new ObjectMapper();

		Child1 child1 = new Child1();
		child1.SerializeMe = 3;
		child1.dontSerializeMe = 12;
		String outputChild1 = oMapper.writeValueAsString(child1);
		System.out.println(outputChild1);
		ParentClass inputChild1 = oMapper.readValue(outputChild1, ParentClass.class);
		System.out.println(((Child1) inputChild1).SerializeMe);
	} catch (Exception ex) {
		ex.printStackTrace();
	}
}

{% endhighlight %}
&nbsp;

<h3>Source code</h3>

The source code for this project is released under the <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/Licensing.txt'>BSD License</a> and can be downloaded <a href='http://www.techtraits.ca/wp-content/uploads/2011/11/custom_serializer.zip'>here</a>. 


<h3>External Links</h3>


<ul>
	<li><a title="Jackson" href="http://jackson.codehaus.org/">http://jackson.codehaus.org/</a></li>
	<li><a href="http://jackson.codehaus.org/1.9.0/javadoc/index.html" title="Object Mapper" target="_blank">Object Mapper</a></li>
	<li><a href="http://jackson.codehaus.org/1.7.0/javadoc/org/codehaus/jackson/map/SerializationConfig.Feature.html" title="Serialization Config" target="_blank">Jackson serialization config</a></li>
	<li><a href="http://jackson.codehaus.org/1.2.1/javadoc/index.html?org/codehaus/jackson/map/annotate/JsonSerialize.html" title="JSONSerializer" target="_blank">Json Serializer</a></li>

</ul>
