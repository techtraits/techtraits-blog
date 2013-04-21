--- 
layout: post
title: In defence of the lowly singleton
date: 2013-04-07 10:46:28
authors: 
- usman
categories: 
- Programming
tags:
- code

---

The singleton pattern takes a lot of flack as being an anti-pattern. Some of it may be well deserved, as with all patterns if used badly the it can lead to code which is difficult to maintain and test. However the vitrol directed at singletons is some what un called for. Singletons have been called "[Pathological Liars](http://misko.hevery.com/2008/08/17/singletons-are-pathological-liars/)"  and "[Glorified global state](http://lucumr.pocoo.org/2009/7/24/singletons-and-their-problems-in-python/)". A good summary of the haters can be found on [stackoverflow](http://stackoverflow.com/questions/137975/what-is-so-bad-about-singletons) and is enumerated below.  

> 1. They are generally used as a global instance, why is that so bad? Because you hide the dependencies of your application in your code, instead of exposing them through the interfaces. Making something global to avoid passing it around is a code smell.
> 2. They violate the Single Responsibility Principle: by virtue of the fact that they control their own creation and lifecycle. 
> 3. They inherently cause code to be tightly coupled. This makes faking them out under test rather difficult in many cases.
> 4. They carry state around for the lifetime of the app. Another hit to testing since you can end up with a situation where tests need to be ordered which is a big no no for unit tests. Why? Because each unit test should be independent from the other.

While all of these criticisms are true of misused singletons they are not an inherent drawback of the pattern. We are doing a disservice to junior developers by removing singletons from their tool box. Using dependency injection we can write concise, readable, testable and maintainable singletons. Furthermore the [usual suggestion](http://misko.hevery.com/2008/08/21/where-have-all-the-singletons-gone/) is to use Factories to create and maintain a set of objects of similar lifetimes and concerns. This often leads to code which is more complicated, error prone and difficult to maintain than singletons ever were.  

## Singleton are global instances

One of the primary criticisms Singletons is that they hide dependency trees  because they are global instances accessed statically. This is no longer true with dependency injection as we can have singletons which are injected into objects as needed. For example the code below shows how I would create and use a singleton with the [Guice](http://code.google.com/p/google-guice/) framework. Each class which requires the instance has a clear dependency on it and there is access to that object from global scope. 

{% highlight java %}
@Singleton
public class MySingleton {
	//Some code here
}

public interface SomeInterface {

	public String doSomething(SomeObject someObject);
}

public class SomeInterfaceImplementation {

	private final MySingleton singleton;
	
	@Inject
	public SomeInterfaceImplementation (MySingleton singleton) {
		this.singleton = singleton;
	}
	
	public String doSomething(SomeObject someObject) {
		//... Some code
	}	
}
{% endhighlight %}

##Singletons are difficult to test

One claim that is often thrown around is that singletons are difficult to unit test and bleed state between tests. While this may have been true at some point with dependency injection and modern testing frameworks this is no longer true. There are a host of mocking libraries such as [Mockito](http://code.google.com/p/mockito/), [EasyMock](http://www.easymock.org/) which make it easy replace singletons during tests. With dependency injection the code being tests does not even need to be aware of wether the mock or real implementation is running. For example in the code above if I needed to unit test the SomeInterfaceImplementation class I would just use mocktio and get something similar to the code below:

{% highlight java %}

	MySingleton mockSingleton = mock(MySingleton.class);
	SomeInterfaceImplementation someImpl = new SomeInterfaceImplementation(mockSingleton);
	when(mockSingleton.getSomething()).return("Something");
	someImpl.doSomthing("SomeString");
	//assertSomething
	
 
{% endhighlight %}

The code is concise and it is immediately clear exactly how the singleton will interact with the code being tested as all the mocked calls are written into the test. 

## Singleton are "glorified global state"

Another similar criticism levelled at singletons is that they are just glorified shared state and not useful for much else. The first thing to note is that modern services tend to have a lot of immutable shared state or shared state that has write-one read-many semantics. Examples of such state are static properties such as URLs of external services, health thresholds or location of graphical assets. In such cases having shared state is not a a problem, in fact it is desirable to have shared state so that the entire application has a consistent view of the application. 

Beyond shared state singletons can also ideal places to place stateless shared code. Some common examples of such uses are to write a Rest Wrapper for some external service. For example we often write a singleton wrapper for Facebook's rest interface. We could use a factory to create instances of such an object but 

