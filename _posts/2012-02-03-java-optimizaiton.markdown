--- 
layout: post
title: Java Optimizaiton, Why is my application so slow?
wordpress_id: 808
wordpress_url: http://www.techtraits.com/?p=808
date: 2012-02-03 19:57:36 +00:00
---
<p style="text-align: justify;">

I am currently working on a rest service to support a new game the <a href="http://www.ea.com/" title="Electronic Arts" target="_blank">Electronic Arts</a> is going to be launching. Our mandate is to support 50K-100K concurrent users at launch. After several months of work we had all the features finished and fairly stable but now the time came to measure and optimize performance. I like to think that I am a half decent Java programmer and server engineer so I can read some code and figure out what the performance bottle necks are. However, with any large project the code is too large for manual optimization especially if there is no structural problems for easy wins. How do you find those small bugs that are so easy to miss but make all the difference. There are many articles telling you what structures and architectures work best but very few that tell you what to do if your architecture is fine but the system is still to slow. This article covers how to go about finding what is actually wrong with your server.</p>

<!--more-->



<h3>Keep Score</h3>

<p style="text-align: justify;">

The first thing you need to do is identify the Metric you will use to quantify that there is a problem and how much difference each change makes. Profiles and other tools will give you executions times and percentages of specific parts of the code but you need to have an external metric which captures the bigger picture. A good value for servers is client response time or the number of concurrent users (given an expected user session). For a desktop app it can be the running time of a specific operation or set of operations. </p>



<h3><a href="http://docs.oracle.com/javase/1.5.0/docs/tooldocs/share/jstack.html" title="JStack" target="_blank">Dump some threads with JStack</a></h3>

<p style="text-align: justify;">

A first cut solution is to look at your threads and what they are doing and you can easily do that using the JStack utility. Using this you can take a thread dump of any running java process on your system. Just run get the process id of your application using the ps command and run jstack on that process id. </p>




{% highlight bash %}
$ps -aux | grep java
usman          12438   0.0  0.2  2890624  15356   ??  S     2:36pm   0:00.18 java ........
$jstack 12438
{% endhighlight %}
&nbsp;



<p style="text-align: justify;">

This will list all active threads and also give stack traces of any thread that is in the waiting state. Most modern computers should not be CPU bound so if your app is slow, the CPU(s) and there for threads are usually waiting for something. JStack quickly tells you how many threads are active and what they are waiting for. If there are a lot of waiting threads and the wait is unavoidable then consider using asynchronous code such as <a href="http://docs.oracle.com/javase/1.5.0/docs/api/java/util/concurrent/ExecutorService.html" title="Executor Service" target="_blank">Executor Service</a> or <a href="http://docs.codehaus.org/display/JETTY/Continuations" title="Continuations" target="_blank">Continuations</a>.</p>



<h3><a href="http://java.sun.com/developer/technicalArticles/Programming/HPROF.html" title="HPROF" target="_blank">Look at CPU time with HPROF</a></h3>

<p style="text-align: justify;">

Lets go little deeper into the app using the build in HPROF tool that ships with the Sun/Oracle JVM. With Hprof we can define several profiling metrics that but first lets look at CPU times. Run your application with hprof enabled and configured to capture times:</p>

{% highlight bash %}  
export JAVA_OPTIONS="-agentlib:hprof=cpu=times,thread=y,file=hprof.txt"
java $JAVA_OPTIONS YourApp.java
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">

Once your program runs (and exits) the hprof.txt file will contain a table CPU time details like the one shown below. This shows the methods where the CPU spends most of its execution time. The self coloumn marks the percentage of time used by the method and the accum column describes the total time accounted for so far starting at the top. So reading here thread.start accounts for 0.98% of the time and all methods up to here account for 23.96% of execution time. The trace coloumn allows you to look at the stack trace for that particular type of call. This table is important because it tells you which methods to optimize first and what kind of gains to expect. My trace is fairly innocuous because its from a jetty server coming up but its not uncommon for poorly performing applications to spend 90% of their time in just a handful of methods. One application I was working on with badly configured loggers was spending 90% in just logging, fixing that doubled our concurrent user cap.</p>



{% highlight bash %}  
CPU TIME (ms) BEGIN (total = 11669) Wed Feb  1 19:20:55 2012
rank   self  accum   count trace method
   1  3.50%  3.50%   37272 312412 java.io.BufferedInputStream.read
   2  2.73%  6.23%   37272 312411 java.io.BufferedInputStream.getBufIfOpen
   3  2.44%  8.67%   18636 312413 java.io.DataInputStream.readChar
   4  2.37% 11.05%   34464 312434 java.io.ByteArrayInputStream.read
   5  2.10% 13.15%   10784 312450 java.io.DataInputStream.readChar
   6  1.59% 14.74%    1926 312683 java.lang.String.<init>
   7  1.49% 16.23%    8616 312435 java.io.DataInputStream.readInt
   8  1.37% 17.60%   14976 312676 sun.text.normalizer.Trie.getCodePointOffset
   9  1.14% 18.74%   14976 312678 sun.text.normalizer.NormalizerImpl.getNorm32
  10  1.13% 19.87%    3204 307315 java.lang.Character.toLowerCase
  11  1.05% 20.93%   14335 312674 sun.text.normalizer.Trie.getRawOffset
  12  1.05% 21.98%    4460 314414 java.lang.Character.isJavaIdentifierPart
  13  1.00% 22.98%   14335 312675 sun.text.normalizer.Trie.getBMPOffset
  14  0.98% 23.96%       1 317395 java.lang.Thread.start
  15  0.93% 24.90%     360 313439 java.lang.StringCoding$StringDecoder.decode
  16  0.93% 25.82%     208 300638 sun.misc.ASCIICaseInsensitiveComparator.lowerCaseHashCode
  17  0.88% 26.70%     500 312717 java.text.RBTableBuilder.addExpansion
  18  0.87% 27.58%    2410 300626 java.util.jar.Attributes$Name.isValid
  19  0.87% 28.45%    4987 305903 java.lang.String.charAt
  20  0.85% 29.30%    4986 305947 java.lang.String.charAt
  21  0.84% 30.14%     100 307335 java.util.HashMap.get
  22  0.84% 30.98%    1926 312679 sun.text.normalizer.NormalizerImpl.getExtraDataIndex
  23  0.84% 31.82%    1020 312703 java.lang.Character.codePointAtImpl
  24  0.83% 32.65%     324 312521 java.util.ArrayList.add
  25  0.82% 33.47%      72 315434 java.lang.Character.digit
{% endhighlight %}
&nbsp;


<h3>Count the calls</h3>

{% highlight bash %}  
export JAVA_OPTIONS="-agentlib:hprof=cpu=samples,thread=y,file=hprof.txt"
java $JAVA_OPTIONS YourApp.java
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">

In addition to giving CPU execution times HPROF can also give us counts for how many times a method is executed. In the example you can see that the first 10 methods account for almost 80% of all method calls. So if you would like to reduce calls those ones will be the targets. If the same method shows up on the times and samples table than you have a definite problem as a slow method call is being called very often. </p>



{% highlight bash %}
rank   self  accum   count trace method
   1 19.21% 19.21%     726 300488 java.net.PlainSocketImpl.socketAccept
   2 19.21% 38.41%     726 300514 java.net.PlainSocketImpl.socketAccept
   3 19.21% 57.62%     726 300515 java.net.PlainSocketImpl.socketAccept
   4  9.74% 67.35%     368 301114 sun.nio.ch.EPollArrayWrapper.epollWait
   5  5.85% 73.20%     221 301335 java.net.SocketInputStream.socketRead0
   6  5.74% 78.94%     217 301354 java.net.SocketInputStream.socketRead0
   7  5.24% 84.18%     198 300889 java.util.zip.Inflater.inflateBytes
   8  2.09% 86.27%      79 301396 sun.nio.ch.EPollArrayWrapper.epollWait
   9  1.22% 87.49%      46 300506 java.lang.ClassLoader.defineClass1
  10  0.82% 88.31%      31 301019 sun.net.www.protocol.jar.JarURLConnection.connect
  11  0.77% 89.07%      29 300854 java.lang.ClassLoader.findBootstrapClass0
  12  0.71% 89.79%      27 300890 java.io.FileOutputStream.writeBytes
  13  0.69% 90.48%      26 300908 java.io.FileInputStream.readBytes
  14  0.58% 91.06%      22 300892 java.util.zip.CRC32.updateBytes
  15  0.29% 91.35%      11 301150 sun.net.www.protocol.jar.JarURLConnection.connect
{% endhighlight %}
&nbsp;




<h3>Count the Objects</h3>

<p style="text-align: justify;">

Memory is an important component for optimization and if you are getting out of memory exceptions then you know that your application is in trouble. However there are also more subtle performance implications of memory management. One thing to always check is whether your singletons are actually singletons. In a recent project we used to Google Guice to inject singleton objects using annotations. However in some cases we were using javax.inject.Singletion instead of com.google.inject.Singleton. This small error meant that our singletons weren't actually singletons. This has all sorts of implications including the fact that one of our singleton classes which handled calls to external servers had several thousand instances and thus was holding several thousand connections open. </p>



<p style="text-align: justify;">

Also if your applications memory profile is choppy, i.e. it used very little memory for long periods of times followed by a lot of memory quickly you can get OutOfMemmory Exceptions and long garbage collection delays. Therefore try to minimize the number of objects that need to be created repeatedly (i.e. for each request in case of a server). Any objects that can be singletons should be, any objects can be reused should be. </p>



<p style="text-align: justify;">

We can also get the object allocation information out of HPROF profiling as shown below. The table should the top objects created, the amount of memory they take up. This list will help you find any singletons, which aren't. Also the profile gives you the number of live object of any type and the total objects of that type allocated. This gives you two key information points. If the number of objects allocated is equal to the number of live objects then these objects were never released and garbage collected. Is this expected? Also if the number of allocated objects is much higher than your live objects count than your application is churning a lot of memory. Maybe you should reuse more objects. Also time the constructor of those objects if this will give you a good idea of the performance overhead of creating those objects.   </p>




{% highlight bash %}
export JAVA_OPTIONS="-agentlib:hprof=heap=sites,file=hprof.txt"
java $JAVA_OPTIONS YourApp.java
{% endhighlight %}
&nbsp;



{% highlight bash %}
          percent          live          alloced  stack class
 rank   self  accum     bytes objs     bytes  objs trace name
    1 44.73% 44.73%   1161280 14516  1161280 14516 302032 java.util.zip.ZipEntry
    2  8.95% 53.67%    232256 14516   232256 14516 302033 com.sun.tools.javac.util.List
    3  5.06% 58.74%    131504    2    131504     2 301029 com.sun.tools.javac.util.Name[]
    4  5.05% 63.79%    131088    1    131088     1 301030 byte[]
    5  5.05% 68.84%    131072    1    131072     1 301710 byte[]

{% endhighlight %}
&nbsp;





<h3>External Links</h3>

<p style="text-align: justify;">

	<ul><a href="http://docs.oracle.com/javase/1.5.0/docs/tooldocs/share/jstack.html" title="JStack" target="_blank">JStack</a></ul>

	<ul><a href="http://java.sun.com/developer/technicalArticles/Programming/HPROF.html" title="HPROF" target="_blank">HPROF</a></ul>



