--- 
layout: post
title: Records in erlang
wordpress_id: 34
wordpress_url: http://www.techtraits.ca/?p=34
date: 2011-06-11 23:49:10 +00:00
author: usman
categories: 
- Programming
tags:
- erlang
- code
- records
---
<hr />
<p style="text-align: justify;">
When learning a new language its always difficult to google the meaning of operators. I ran into this problem when reading erlang source and trying to figure out what the hash sign does. Searching for "erlang hash" would always lead to articles about computing MD5 hashes in erlang. I had to resort to asking the question on stack overflow.So for the sake of the next person who googles this "What does the hash operator do in erlang?"
</p>
<!--more-->
&nbsp;
<h3 style="text-align: left;">Defining Records</h3>
<p style="text-align: justify;">
Record is a compound data type in erlang which gives named access to the elements it contains similar to a struct in c. To use records we must fust define their structure:
</p>
{% highlight erlang %}
    -record(record_name, {element_mame=optional_default_value}).
{% endhighlight %}

for example:

{% highlight erlang %}
    -record(car, {model,year,color=blue}).
{% endhighlight %}
&nbsp;
<h3 style="text-align: left;">Initializing Records</h3>
<p style="text-align: justify;">
To initialize we use the aforementioned hash sign as a prefix to the statement. Notice that I can choose not to supply values for the elements, elements with default values will have those assigned others will remain undefined.
</p>
{% highlight erlang %}
    Car1 = #car{model=civic,year=2007,color=green},
    Car2 = #car{model=mazda,color=green}.
{% endhighlight %}
&nbsp;
<h3>Accessing Records</h3>


To access records we use our trusty hash operator again and use the element name to retrieve data:

{% highlight erlang %}
    Car1 = #car{model=civic,year=2007,color=green},
    Car2 = #car{model=mazda,color=green},
    Car1Model = Car1#car.model.
{% endhighlight %}
&nbsp;

<h3>Updating Records</h3>
<p style="text-align: justify;">
Updating records is much like initializing except that any elements that we do not specify values for will retain retain previous values.
</p>
{% highlight erlang %}
    Car1 = #car{model=civic,year=2007,color=green},
    Car2 = #car{model=mazda,color=green},
    Car3 = Car2#car{year=2003}.
{% endhighlight %}
&nbsp;

<h3>Further Reading</h3>

* [Reference Manual](http://www.erlang.org/doc/reference_manual/records.html)
* [Examples](http://www.erlang.org/doc/programming_examples/records.html)



