--- 
layout: post
title: Amazon DynamoDB&#58; Understanding Query and Scan operations
date: 2012-06-25 22:40:01
author: bilal
categories: 
- nosql
- cloud
tags:
- aws
- dynamodb
- nosql
- key-value-store
- Java

---

<p style="text-align: justify;">
<a href="http://aws.amazon.com/dynamodb/">DynamoDB</a> is the latest
nosql-database-as-a-service offering by Amazon. The design of DynamoDB
is based on Amazon's <a
href="http://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf">Dynamo</a>
key-value store, used internally for their e-commerce platform.  

DynamoDB offers two main advantages over SimpleDB (Amazon's initial
NoSQL offering based on Google's <a href="http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/en//archive/bigtable-osdi06.pdf">BigTable</a>):

<ul>
  <li>
  Unlike SimpleDB which has hard limits on request rates (<b>70
  requests/sec</b>) and size (<b>10GB</b>) per domain, DynamoDB can theoretically be
  provisioned for infinite throughput capacity per table. This means that the application doesn't need to shard data into multiple tables to work around the throughput limits.
  </li>
  <li>
  Second, DynamoDB offers faster and more predictable query
  performance, likely due to the restricted data model and the use of faster solid state drives.
  </li>
</ul>
</p>

<p style="text-align: justify;">
At first it may seem that DynamoDB is a direct replacement for
SimpleDB for all use cases. However, you should look at the data model
and query flexibility required for your application and select the
data store that best suites your requirements. Let's take a look at
DynamoDB's data model and the QUERY and SCAN operations with some
examples to better understand the strengths and limitations of DynamoDB. 
</p>

<h3><u>I) Data Model and Access API</u></h3>
&nbsp;

<b>Tables, Items and Attributes</b>

<p style="text-align: justify;">
DynamoDB's data model consists of tables, items and attributes. Each
table is a collection of items and each item is a collection of
attributes. An Attribute is simply a name-value pair, e.g.,
<b>("userId"=1234)</b>. Consider for example a Users table where a
simple user item may look like:</p>

{% highlight java %}
"UserId"=1234
"Name"="Bilal Sheikh"
"DateJoined"=1282512345
"Department"="Development"
{% endhighlight %}
&nbsp;

<b>Primary Key, Composite Key and Indices </b>

<p>Each table must have a primary key attribute which is specified
when the table is created. The primary key attribute must have a value
for all items and the value must be unique. In our user table,
<b>UserId</b> will be the primary key attribute.</p>

<p>Instead of specifying a single attribute as the primary key, a
composite primary key can be specified to collectively act as the
primary key. One attribute acts as a hash index used for partitioning
data while the other attribute acts as a range attribute with a range
index. In our user model a composite primary key of UserId and DateJoined
can specified where UserId would be the hash key and the DataJoined
would serve as the range key. Both attributes making up the composite
key must have a value for all items.</p>

<p><b>Note: </b>The data model is much more restricted than SimpleDB
where indices are created automatically for all attributes. The
restricted data model allows for infinite scalability and fast get and
put operations.</p>

<b>Basic Access API</b>

<p style="text-align: justify;">
DynamoDB offers basic API for table creation and deletion, put, get,
update and delete involving only  one item and batch variants of get and put for combining
multiple get and put operations in a single request. We next look at
in detail the <b>Query</b> and <b>Scan</b> operations.
</p>

<h3><u>II) Query</u></h3>

<p style="text-align: justify;">

</p>

<h3><u>III) Scan</u></h3>

<p style="text-align: justify;">

</p>


<h5>Examples</h5>
<h5>Cost of Query and Scan operations</h5>

<h5>Workarounds</h5>
<h5>Ghost Records or Application Managed Indexes</h5>
<h5>Perform bulk actions with single scans</h5>


<h5>If still not enough go with less performant SimpleDB which offers
query flexibility -- DynamoDB is Not the right choice </h5>

<h3>External Links</h3>

<a href="http://aws.amazon.com/dynamodb/#whentousedynamodb">DynamoDB Data Model</a>  
<a
href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/QueryAndScan.html">DynamoDB
developer guide</a>
