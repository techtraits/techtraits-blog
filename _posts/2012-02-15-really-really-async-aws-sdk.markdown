--- 
layout: post
title: Really Really Async AWS SDK
wordpress_id: 930
wordpress_url: http://www.techtraits.com/?p=930
date: 2012-02-15 00:14:00 +00:00
author: usman
categories: 
- Programming
tags:
- java
- code
- aws
- amazon
---
<p style="text-align: justify;">
Like much of the world I use Amazon services and the Aws SDK (Java in our case) to support our scalable web service. In an effort to maximize the number of users we could support per machine we use a asynchronous request processing architecture using <a href="http://docs.codehaus.org/display/JETTY/Continuations" title="Contiuations" target="_blank">jetty continuations</a>. In such a setup we needed an asynchronous AWS SDK. Now you might say the AWS SDK already provides asynchronous an API, and you would be right. However, the asynchronous AWS still return a future and require the calling code to poll the future and look at responses once it is done. We wanted a really really asynchronous API which we could say "Hey do X, and when you are done do Y if there is an error Z but no matter what happens don't bother me again". Since there was no such API we decided to implement it ourselves and you can find it <a href="https://github.com/techtraits/aws-sdk-for-java" title="Tech traits Aws SDK for Java" target="_blank">here</a></p>. 

<!--more-->

<p style="text-align: justify;">
The use case I describe above is facetious but its remarkably useful. For example say your server has to save something to <a href="http://aws.amazon.com/dynamodb/" title="DynamoDB" target="_blank">DynamoDB</a>. You callputItemAsync and get a future object back. The SDK uses an internal thread pool to get a thread and uses that thread to send a blocking http call to Amazon. Once that is done the internal thread sets the done field of the future to true. In the meantime you own code is periodically checking (or waiting) for the future to complete.</p>




{% highlight java %}

Future<PutItemResult> future = awssdk.putItemAsync(putItemRequest)
while(future.isDone() == false) {
        //Twiddle my thumbs.
}
PutItemResult result = future.get();
//No errors, cool lets ignore the result
{% endhighlight %}




<p style="text-align: justify;">
You should begin to see the problem here. There are two threads blocked doing nothing (or one blocked and one polling) while they could be doing meaningful work. Furthermore for a lot of times we don't even really care about the response from Amazon other than to log an error if needed. There is no reason why the rest of the request should wait for a put item to complete its not like we are retrieving information we need later. To get around this issue we added the <a href="https://github.com/techtraits/aws-sdk-for-java/blob/master/src/main/java/com/amazonaws/AsyncServiceHandler.java" target="_blank">AsyncServiceHandler.java</a></p>. 



{% highlight java %}
awssdk.putItemAsync(putItemRequest,new AsyncServiceHandler<PutItemResult, 
                PutItemRequest>() {

        @Override
        public void handleResult(PutItemResult arg0, PutItemRequest arg1) {
                //Do something here if you must  
        }

        @Override
        public void handleException(Exception arg0) {
                //Log an exception and retry if you want    
        }

        @Override
        public void handleException(AmazonClientException arg0) {
                //Log an exception and retry if you want
        }

        @Override
        public void handleException(AmazonServiceException arg0) {
                //Log an exception and retry if you want
        }
    });
{% endhighlight %}




<p style="text-align: justify;">

In this implementation you get the same great feature but with 0% thumb twiddling. The internal thread still blocks when making the request to Amazon but once its done it just calls the result or error handlers as needed. Your main thread never check request status. </p>



<p style="text-align: justify;">

As a side bar you may ask why did we implement three error case handlers, and if you look at it closely they are all in the same inheritance tree. AmazonServiceException is a child of AmazonClientException which a child of  Exception. The AmazonServiceException has a much cleaner interface to find out what went wrong if the error was server side, AmazonClientException will catch server side as well as client side errors but its much more difficult finding out what happened in case of server side errors. And we define a handler for the plain old exception class to catch any other errors that may happen. We could have used if (arg0 instanceOf AmazonServiceException) to check the error type but that is just gross.  

</p>



<p style="text-align: justify;">

Do I hear anyone ask "How do I get this awesome new API?" well we have finished the implementation for DynamoDB and will integrate with the rest of the services very soon. We have already submitted a patch to Amazon hopefully this code or something similar will be in the master branch soon. Until then you can build and deploy the code as follows:

</p>

{% highlight bash %}

git clone git@github.com:techtraits/aws-sdk-for-java.git
cd aws-sdk-for-java
#Some hacking see below
mvn clean install
#Copy to your nexus repo

{% endhighlight %}



The hacking required is to edit the pom.xml file as follows:

* Change the version from &lt;version&gt;1.3.2&lt;/version&gt; to something like &lt;version&gt;1.3.2_hacked&lt;/version&gt;

* You should also delete the gpg signing plugin unless you really really want signed code

{% highlight bash %}
      <plugins>
        <plugin>
          <groupId>org.apache.maven.plugins</groupId>
          <artifactId>maven-gpg-plugin</artifactId>
          <version>1.4</version>
          <executions>
            <execution>
              <id>sign-artifacts</id>
              <phase>verify</phase>
              <goals>
                <goal>sign</goal>
              </goals>
            </execution>
          </executions>
        </plugin>
      </plugins>
{% endhighlight %}

* And you are all set just deploy the compiled jar to your maven repo
* In true cooking show fashion <a href='http://www.techtraits.com/wp-content/uploads/2012/02/aws-java-sdk-1.3.2_edited.jar'>here</a> is one I built earlier.










