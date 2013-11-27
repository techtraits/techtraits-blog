--- 
layout: post
title: No more interfaces please
date: 2013-11-27 14:21:52
authors: 
- usman
categories: 
- Programming
tags:
- Java
permalink: /nointerface
---

Interfaces in Java can be very useful at times. When you have multiple implementations of a service and want to enforce a contract on all of those implementation by all means use an interface. However, a lot of Java programmers are abusing interfaces and inserting them where they have no business being. This article is my rant on some of the most heinous uses of interfaces.

One of the best examples of this is interfaces used for unnecessary future-proofing. For example, a project I am currently working on is rife with *FooInterface* and *DefaultFooImplementation*. If you cannot come up with a better prefix for your interface implementation than "Default" then there is a fairly good chance you should not be using an interface. Whenever I advocate for the removal of such unnecessary interfaces I always get push back. Dome of the major reasons for interfaces as future-proofing are:

1. What if the implementation changes? 
1. What if we need two implementations with an interface we can choose implementation without changing code already using the interface?

For one my follow up question is what if it does? You should just update the original class rather than writing a new class which adds unnecessary code to the project and leaves dead code sitting around. Should ever need the old implementation back you always have commit history in your source control system. We always think that extra code is harmless but reams of dead code is one of the primary road-blocks in ramping up new developers on a legacy code base. At any given time the code-base should only contain code that is being used at that time. This makes the developers' intent clear and makes it much easier for new team members to understand and change code. 

The second reason is a little more complicated to respond too. True, advantage of interfaces is that the downstream classes are unaware of the implementation details of the implementation class. This means they implementation class can be swapped out without changing downstream class. However, this is also true if we just used inheritance to sub-class the implementation when we need special cases. This can also be achieved without changing downstream code. The advantage of using this approach is that you do not need to create the second child class ahead of time. You can just code your one class e.g. LoginService and if there arises a point in the future where you need FacebookLoginService and GoogleLoginService you can just re-purpose LoginService as an abstract class and add the sub-classes as needed. The end product of Interface and Abstract classes may be the same but with the Abstract class you do not write the additional types until its actually needed. 

Another reason that people often point to when justifying the use of interfaces is that Interfaces can live in their own jar/project and the implementations can live in separate projects. This allows for downstream project to pick and choose which implementation to use for each interface by selecting the relevant jar as a dependency. This use again is valid if and only if you *do* compile interfaces in a separate project from the implementation. If you are writing a general purpose open source library or even a closed source one that is going to be used by many teams in your organization then by all means split out your interfaces and implementation into their own projects. If on the other hand you are the sole user of your library or the use-case of the library is specific enough that there will never be case where underlying implementation can change without requiring downstream changes then why add the extra hassle of compiling multiple projects for every small change. 

Stepping back the abuse of interfaces is just a manifestation of an outlook to programming where you try to anticipate every use of your project ahead of time and code defensively. This made a lot of sense in the waterfall days where going back to refactor code was expensive and undesirable. In modern agile days refactors happen all the time. Rather than trying to avoid them lets embrace them. By keep code as simple as possible and focused on the current problem we may be setting ourselves up for lots of refactors. However, that is ok because the simplicity means we can re-write quickly, write better tests, maintain tests as code changes, reduce the ramp-up time for new developers. If we do not adhere to a more spartan approach too code we can easily end up in the absurd situation highlighted by [Enterprise Class FizzBuss](https://github.com/EnterpriseQualityCoding/FizzBuzzEnterpriseEdition).


