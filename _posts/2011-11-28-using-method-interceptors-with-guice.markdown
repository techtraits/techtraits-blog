--- 
layout: post
title: Using method interceptors with Guice
wordpress_id: 664
wordpress_url: http://www.techtraits.ca/?p=664
date: 2011-11-28 01:20:04 +00:00
authors: 
- usman
categories: 
- Programming
tags:
- Java
- code
- Guice
- Annotations
- Method Interceptors
---


The <a href="http://code.google.com/p/google-guice/" title="Guice" target="_blank">Guice</a> dependency injection library from Google comes with a whole host of added goodies including Method interception. I have been somewhat obsessed with code quality of late and wanted to use method interception to this end. This article talks about using method interceptors to inspect the parameters for a method and implement boiler plate checks such as null parameters without code repetition. As a simple example I will be implementing a check for null arguments. 

<!--more-->

<h3>Source code</h3>



As a starting point of this implementation I will be using the sample code from an earlier article [Setting up a webservice using Guice & Sitebricks](/Programming/Java/2011/06/25/Setting-up-a-webservice-using-Guice-Sitebricks/)</strong> which can be downloaded from [github](https://github.com/techtraits/guice-server-example). The completed project code can also be downloaded from github [here](https://github.com/techtraits/guice-methodinterceptor-example).The source code for this project is released under the [BSD License](/assets/Licensing.txt).



<h3>Defining the annotation</h3>


In order to mark the methods for which we wish to ensure non-null parameters we will define a custom Annotation "NotNull". The code for defining an annotation is shown below. We are defining that this is a <font color="green">Runtime</font> annotation using the <font color="green">@Retention</font> meta annotation. Similarly we use the <font color="green">@Target</font> meta annotation to define that this annotation can only be applied to methods. 



{% highlight java %}

package com.flybynight.helloworld;

import java.lang.annotation.ElementType;
import java.lang.annotation.Retention;
import java.lang.annotation.RetentionPolicy;
import java.lang.annotation.Target;

@Retention(RetentionPolicy.RUNTIME)
@Target({ ElementType.METHOD })
public @interface NotNull {



}
{% endhighlight %}
&nbsp;



<h3>Defining the method interceptor</h3>



In order to create our method interceptor we create a class to implement the <font color="green">org.aopalliance.intercept.MethodInterceptor</font> interface and override the <font color="green">invoke</font> method. We get an instance of the <font color="green">org.aopalliance.intercept.MethodInvocation</font> class passed into the invoke method as a parameter. we can then query the getArguments method of the MethodInvocation class to retrieve all of the arguments. As shown in the code below we then traverse the list of arguments and check if they are null. We could implement any number of validation checks on the arguments at this point. If any of the validations fail we would throw an exception with details of the faliure. 



{% highlight java %}

package com.flybynight.helloworld;

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

public class NotNullInterceptor implements MethodInterceptor {

	@Override
	public Object invoke(MethodInvocation invocation) throws Throwable {

		Object[] args = invocation.getArguments();
		for (int i = 0; i < args.length; i++) {
			if (args[i] == null) {
				String argType = invocation.getMethod().
					getParameterTypes()[i].getCanonicalName();
				throw new NullPointerException("Argument " + i + " of Type "
					+ argType + " should never be null.");
			}
		}
		return invocation.proceed();
	}
}
{% endhighlight %}
&nbsp;





<h3>Configure interception</h3>



In order for the interceptor to be invoked we must configure guice to link the annotation to the interceptor. We do this in the GuiceCreater class as part of the bind function of the sitebricks module. We use the <font color="green">bindInterceptor</font> call to link all elements (Matchers) annotated with our <font color="green">NotNull</font> annotation to our interceptor class <font color="green">NotNullInterceptor</font>. 



{% highlight java %}
bindInterceptor(Matchers.any(), Matchers.annotatedWith
	(NotNull.class), new NotNullInterceptor());
{% endhighlight %}
&nbsp;



<h3>Testing the code</h3>

Now all that is left is to take our interceptor for a spin. Create a <font color="green">doSomething(String something)</font> method in the HelloWorld sitebrick (HelloWorld.java). and annotate the method with the NotNull. Also call the method with a null parameter. See code below. 


{% highlight java %}
package com.flybynight.helloworld.sitebricks;

import com.flybynight.helloworld.NotNull;
import com.google.inject.Inject;
import com.google.inject.name.Named;
import com.google.sitebricks.At;
import com.google.sitebricks.http.Get;

@At("/helloworld")
public class HelloWorld {

	@Inject
	@Named("message")
	String messageString;

	public String getMessage() {
		doSomething("Some"); //Should Pass
		doSomething(null); //Will fail

    	return this.messageString;		
	}

	@NotNull
	public void doSomething(String something) {

	}
}
{% endhighlight %}
&nbsp;

Now compile the code using mvn clean install and run it using mvn jetty:run (See [Setting up a webservice using Guice & Sitebricks"](/Programming/Java/2011/06/25/Setting-up-a-webservice-using-Guice-Sitebricks/) for details). To run the code browse to http://localhost:8080/helloworld. 

{% highlight bash %}
Problem accessing /helloworld. Reason:
Exception [NullPointerException - "Argument 0 of Type java.lang.String should never be null."] 
	thrown by event method [public void com.flybynight.helloworld.sitebricks.HelloWorld.get()]
	at com.flybynight.helloworld.NotNullInterceptor.invoke(NotNullInterceptor.java:15)
	.....
{% endhighlight %}
&nbsp;




<h3>Conclusions</h3>

Method interceptors can be useful for a variety of things and a lot of boiler plate code can be written once and hidden away within interceptors. There are other solutions available for the null argument check we can implement a whole host of project specific or domain specific annotations and validation checks. 



<h3>External Links</h3>



<ul>
	<li><a href="http://code.google.com/p/google-guice/" title="Guice" target="_blank">Google Guice</a></li>
</ul>





