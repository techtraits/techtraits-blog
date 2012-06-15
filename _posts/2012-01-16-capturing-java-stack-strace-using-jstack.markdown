--- 
layout: post
title: Capturing Java Stack Strace Using JStack
wordpress_id: 749
wordpress_url: http://www.techtraits.com/?p=749
date: 2012-01-16 16:16:46 +00:00
---
Recently I needed to profile a large distributed web app that was having performance problems. Although I had success using YourKit, it requires us to capture more specific details but it requires restarting a client with profiling enabled. The profiling adds its own overhead to the application and makes it harder to diagnose performance problems. This is where the JStack tool comes in, given the process id (PID) of any java process we can run jstack to capture a stack traces for all threads. An example of the output of the command is shown below. 
<!--more-->
<pre lang="bash">
jstack 19012 > thread_dump
cat thread_dump
</pre>

<pre lang="bash">
Full thread dump OpenJDK Client VM (19.0-b09 mixed mode, sharing):

"Attach Listener" daemon prio=10 tid=0x0a482400 nid=0x5105 waiting on condition [0x00000000]
   java.lang.Thread.State: RUNNABLE

"qtp22874133-506" prio=10 tid=0x09c85400 nid=0x4fc7 waiting on condition [0xb0e7a000]
   java.lang.Thread.State: TIMED_WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x6c760f50> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
        at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:226)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2081)
        at org.eclipse.jetty.util.BlockingArrayQueue.poll(BlockingArrayQueue.java:320)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.idleJobPoll(QueuedThreadPool.java:512)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.access$600(QueuedThreadPool.java:38)
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:558)
        at java.lang.Thread.run(Thread.java:636)

"qtp22874133-505" prio=10 tid=0x0a4c9800 nid=0x4fc6 waiting on condition [0xb13db000]
   java.lang.Thread.State: TIMED_WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x6c760f50> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
        at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:226)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2081)
        at org.eclipse.jetty.util.BlockingArrayQueue.poll(BlockingArrayQueue.java:320)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.idleJobPoll(QueuedThreadPool.java:512)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.access$600(QueuedThreadPool.java:38)
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:558)
        at java.lang.Thread.run(Thread.java:636)

"qtp22874133-504" prio=10 tid=0x0a485800 nid=0x4fc5 waiting on condition [0xb2176000]
   java.lang.Thread.State: TIMED_WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x6c760f50> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
        at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:226)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2081)
        at org.eclipse.jetty.util.BlockingArrayQueue.poll(BlockingArrayQueue.java:320)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.idleJobPoll(QueuedThreadPool.java:512)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.access$600(QueuedThreadPool.java:38)
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:558)
        at java.lang.Thread.run(Thread.java:636)

"qtp22874133-503" prio=10 tid=0x0a4b3400 nid=0x4fc4 waiting on condition [0xb189a000]
   java.lang.Thread.State: TIMED_WAITING (parking)
        at sun.misc.Unsafe.park(Native Method)
        - parking to wait for  <0x6c760f50> (a java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject)
        at java.util.concurrent.locks.LockSupport.parkNanos(LockSupport.java:226)
        at java.util.concurrent.locks.AbstractQueuedSynchronizer$ConditionObject.awaitNanos(AbstractQueuedSynchronizer.java:2081)
        at org.eclipse.jetty.util.BlockingArrayQueue.poll(BlockingArrayQueue.java:320)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.idleJobPoll(QueuedThreadPool.java:512)
        at org.eclipse.jetty.util.thread.QueuedThreadPool.access$600(QueuedThreadPool.java:38)
        at org.eclipse.jetty.util.thread.QueuedThreadPool$3.run(QueuedThreadPool.java:558)
        at java.lang.Thread.run(Thread.java:636)
</pre>
