--- 
layout: post
title: Monitoring python servers with pyformance and graphite
date: 2013-02-17 18:46:14
authors: 
- usman
categories: 
- Programming
- Monitoring
- Python
tags:
- Monitoring
- Graphite

---
{% image /assets/images/monitor.jpg class="monitor_everything" style="float:left" alt="Monitor all the things" class="pimage" %}

I am a strong believer in the [Monitor Everything](http://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/) Philosophy. There are a glut of tools which will monitor system health, many without requiring any code changes. However, these tools generally ignore the most important metrics of all: Application Specific metrics. Such tools can tell us that response times are slow or that a particular server instance is using too much memory but not why. This is where application specific metrics come in. To this end I have made extensive use of [Graphite](http://graphite.wikidot.com/) in conjunction with Coda Hale's [Metrics Library](https://github.com/codahale/metrics) for Java. This allows us to collect metrics about anything and everything the system is doing. We count, measure rate, measure delay and even look at distributions of events. 

This can sound very resource intensive, for example one of the systems I work with is the backend service for [Simpsons Tapped Out](https://itunes.apple.com/ca/app/the-simpsons-tapped-out/id497595276) for which we have millions of active users and hundreds of server instances. We generate approximately fifty thousand unique metric values which are all updated once a minute. This can seem prohibitively expensive but one important fact to leverage to our advantage is that we already over-provision our application servers to handle sudden increases in traffic. This means there is a lot of  idle computation power and memory at any given time. The metrics library we use puts the onus of computing running averages, distributions and storing metrics values on the node themselves. Then in a background thread once a minute all metrics stored on a server are sent graphite in a single request. Since all client-serving code is updating metrics in local memory there is no response time implication of using metrics. Similarly since metrics are sent to graphite in summarized batched form we are not consuming large amounts of bandwidth. 

Since this approach has been so useful to us I wanted to use a similar setup to report metrics out a Python based project I am working on. This article describes the steps necessary to implement efficient metrics collection in python using the [pyformance](https://github.com/usmanismail/pyformance) library.    


# Create Sample Server

Before we add monitoring lets create a server which we are going to monitor. We are going to be using the [Twisted framework](http://twistedmatrix.com/trac/) to create a very simple HelloWorld server, code shown below. Run the server and point your browser to http://localhost:8001 and confirm that you get "HelloWorld" as the response.

{% codeblock Sample Server lang:python %}
#!/usr/bin/python
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.resource import Resource

#This is the request handler use by twistedweb
class RequestHandler(Resource):

    isLeaf = True
    def render_GET(self,request):
        request.setResponseCode(200)
        return "HelloWorld"


if __name__ == '__main__':
    #Load up twisted web
    try:
        resource = RequestHandler()
        factory = Site(resource)
        reactor.listenTCP(8001,factory)
        reactor.run()
    except Exception as e:
        print(e)
{% endcodeblock %}



# Compiling and installing Pyformance

Before we add metrics to our project we need to install the pyformance module. You can install the standard module from [pip](http://pypi.python.org/pypi/pip). However, I am going to be using [my fork](https://github.com/usmanismail/pyformance) of the project which adds support for connections to graphite. In order to compile and install pyformance,  clone the github repo at usmanismail/pyformance and run setup.py with the build and install commands as shown below. 

{% codeblock Installing Pyformance lang:bash %}
git clone git://github.com/usmanismail/pyformance.git
cd pyformance
python setup.py build
sudo python setup.py install
{% endcodeblock %}





Now we can import the pyformance metric classes and the MetricsRegistry into our hello world server (Lines 6 & 7). We then create an instance of MetricsRegistry and assign it global scope (Lines 22 & 23). Lastly we get an instance of a counter metric (Line 14) and then increment and print its value on Line (15 & 16). Run the hello world server again and notice the counter increasing with each request.



{% codeblock Basic Metrics lang:python %}
#!/usr/bin/python
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.resource import Resource
#Import the metric objects from pyformance
from pyformance.meters import Counter, Histogram, Meter, Timer
from pyformance.registry import MetricsRegistry

#This is the request handler use by twistedweb
class RequestHandler(Resource):

    isLeaf = True
    def render_GET(self,request):
    	counter = metricsRegistry.counter("hello_called")
    	counter.inc()
    	print (counter.get_count())
        request.setResponseCode(200)
        return "HelloWorld"

if __name__ == '__main__':
    #Load up twisted web
    global metricsRegistry
    metricsRegistry = MetricsRegistry()
    try:
        resource = RequestHandler()
        factory = Site(resource)
        reactor.listenTCP(8001,factory)
        reactor.run()
    except Exception as e:
        print(e)
{% endcodeblock %}


# Complex Metrics


Having a counter in code is useful but does not need a whole library. The real value of of pyformance is in more complex metrics such as histograms. Histograms calculate the distribution of a random event such as response times and packet sizes. In our example we will now accept a client side parameter "world_size" as a query string variable. Line 15,  16 and 17 in the code below show how we create and update a histogram metric. 

{% codeblock Complex Metrics lang:python %}
#!/usr/bin/python
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.resource import Resource
#Import the metric objects from pyformance
from pyformance.meters import Counter, Histogram, Meter, Timer
from pyformance.registry import MetricsRegistry

#This is the request handler use by twistedweb
class RequestHandler(Resource):

    isLeaf = True
    def render_GET(self,request):
        counter = metricsRegistry.counter("hello_called").inc()
        world_size = request.args["world_size"][0]
        histogram = metricsRegistry.histogram("world_size");
        histogram.add(int(world_size))
        request.setResponseCode(200)
        return str(metricsRegistry._get_histogram_metrics("world_size"))

if __name__ == '__main__':
    #Load up twisted web
    global metricsRegistry
    metricsRegistry = MetricsRegistry()
    try:
        resource = RequestHandler()
        factory = Site(resource)
        reactor.listenTCP(8001,factory)
        reactor.run()
    except Exception as e:
        print(e)
{% endcodeblock %}




Test the code by entering the following URL in your browser [http://localhost:8001?world_size=X](http://localhost:8001?world_size=X) where X is any number. In response you will now see something like:

{% codeblock Metrics Response lang:js %}
{
	'count': 3.0,
	'999_percentile': 15,
	'std_dev': 6.928203230275509,
	'99_percentile': 15,
	'min': 3,
	'95_percentile': 15,
	'max': 15,
	'avg': 7.0,
	'75_percentile': 15
}	
{% endcodeblock %}


# Getting Data to Graphite


Having access to metric values on a node is only marginally useful; we now need to get these values to graphite where we can graph them over time and aggregate values from all our deployed nodes. For this we use a service called [HostedGraphite](https://www.hostedgraphite.com/). You can get a free trial account for hosted graphite [here](https://www.hostedgraphite.com/signup/). Once you have an account click the Account tab and you should see something like the page below. From here copy your API Key. 

![Hosted Graphite](/assets/images/hostedgraphite.png)



In order to push the metrics to Hosted Graphite we need to import (Line 8) and create an instance of (Line 26) Hosted Graphite Reporter. The reporter needs an instance of the metrics registry, the time interval after which to report metrics to Graphite and your Hosted Graphite API Key. In the example below I am using an 10s interval between calls to push metrics. If you run your server again and send some requests to update the metrics, you should now see metrics values in Hosted Graphite under the Composer tab.

{% codeblock Reporting to graphite lang:python %}
#!/usr/bin/python
from twisted.internet import reactor
from twisted.web.server import Site
from twisted.web.resource import Resource
#Import the metric objects from pyformance
from pyformance.meters import Counter, Histogram, Meter, Timer
from pyformance.registry import MetricsRegistry
from pyformance.reporters import HostedGraphiteReporter

#This is the request handler use by twistedweb
class RequestHandler(Resource):

    isLeaf = True
    def render_GET(self,request):
        counter = metricsRegistry.counter("hello_called").inc()
        world_size = request.args["world_size"][0]
        histogram = metricsRegistry.histogram("world_size");
        histogram.add(int(world_size))
        request.setResponseCode(200)
        return str(metricsRegistry._get_histogram_metrics("world_size"))

if __name__ == '__main__':
    #Load up twisted web
    global metricsRegistry
    metricsRegistry = MetricsRegistry()
    reporter = HostedGraphiteReporter(metricsRegistry, 10, "XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX")
    try:
        resource = RequestHandler()
        factory = Site(resource)
        reactor.listenTCP(8001,factory)
        reactor.run()
    except Exception as e:
        print(e)
{% endcodeblock %}        
