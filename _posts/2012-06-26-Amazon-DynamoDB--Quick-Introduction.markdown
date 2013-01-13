--- 
layout: post
title: DynamoDB&#58; Quick Introduction
date: 2012-06-26 21:00:01
author: bilal
categories: 
- cloud
- nosql
tags:
- aws
- dynamodb
- nosql
- key-value store
- Java
- modeling

---

<p style="text-align: justify;">
<a href="http://aws.amazon.com/dynamodb/">DynamoDB</a> is the latest
nosql-database-as-a-service offering by Amazon. The design of DynamoDB
is based on Amazon's <a
href="http://www.allthingsdistributed.com/files/amazon-dynamo-sosp2007.pdf">Dynamo</a>
key-value store used internally for their e-commerce platform.  

DynamoDB offers two main advantages over SimpleDB (Amazon's initial
NoSQL offering based on Google's <a href="http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/en//archive/bigtable-osdi06.pdf">BigTable</a>):

<ul>
  <li>
  Unlike SimpleDB which has limits on request rate and total size (<b>10GB</b>) per domain, DynamoDB can theoretically be
  provisioned for infinite throughput capacity per table. This means
  that DynamoDB takes care of sharding data.
  </li>
  <li>
  Second, DynamoDB offers faster and more predictable query
  performance by offering a restricted data model and utilizing solid
  state drives.
  </li>
</ul>
</p>

<p style="text-align: justify;">
At first it may seem that DynamoDB is a direct replacement for
SimpleDB for all use cases. However, you should look at the data model
and query flexibility required for your application and select the
data store that best suites your application's needs. Let's take a look at
DynamoDB's data model and the QUERY and SCAN operations with some
examples to better understand the strengths and limitations of DynamoDB. 
</p>

<h5>Data Model:</h5>
&nbsp;

<b>Tables, Items and Attributes</b>

<p style="text-align: justify;">
DynamoDB's data model consists of tables, items and attributes. Each
table is a collection of items and each item is a collection of
attributes. An Attribute is simply a name-value pair, e.g.,
<b>("userId"=1234)</b> in a users table. Consider for example a Users table where a user item may look like:</p>

{% highlight java %}
Users
=====
"UserId"=1234
"Name"="Bilal Sheikh"
"City"="Waterloo"
...
...

Posts
=====
"PostId"=345
"Version"=2
...
...

{% endhighlight %}

&nbsp;

<b>Primary Key, Composite Key and Indices </b>

<p>Each table must have a primary key attribute which is specified
when the table is created. The primary key attribute must have a value
for all items and the value must be unique. In our User table,
<b>UserId</b> is the primary key attribute.</p>

<p>Instead of specifying a single attribute as the primary key, a
composite primary key can be specified on two attributes. Hash index used for partitioning
data is created for one of the attributes and a range index in created
for the second attribute. In our Posts model a composite primary key of UserId and DateTime
can be specified where UserId will be the hash key and DateTime
will be the range key. Both attributes making up the composite
key must have a value for all items.</p>

<p><b>Note: </b>The data model is much more restricted than SimpleDB
where indices are created automatically for all attributes. The
restricted data model allows for infinite scalability and fast get and
put operations.</p>

<h5>Basic API and provisioning:</h5>
&nbsp;
<p style="text-align: justify;">
DynamoDB offers basic API for table creation, deletion and updating
read/write provisioning for the table. Put, get, update and delete
operations are supported for individual items. Updates can be
conditional and are can be used for optimistic concurrency control. We next look in detail the <b>Query</b> and <b>Scan</b> operations.
</p>

For each DynamoDb table we need to specify the read and the write
provisioning. Read or write unit capacity is measured as the number of
1KB items read or written per second. For example, if we provision for
5 read units for a table we can execute 100 read requests in a second
where each request read 50 bytes of data. Alternatively, only two
requests would be executed if each request reads 2Kb of data. The read
and write capacity limits the total bytes of data read or written per
second. More detail regarding calculation of read and write units can
be found <a href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/WorkingWithDDTables.html#CapacityUnitCalculations">here</a>. 

<h3>External Links</h3>

<a href="http://aws.amazon.com/dynamodb/#whentousedynamodb">DynamoDB Data Model</a>
