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

<h3><u>I) Quick Tour: Data Model, API and Cost</u></h3>
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
"Posts"= {"565", "345", "467", "740", "331"}
"Friends"= {"2321", "2321", "3232", "6456", "3432"}
"FacebookId"="600323223"
"City"="Waterloo"

Posts
=====
"PostId"=345
"DateTime"=1286751823
"Title"="Jackson Optimization, Using Non-Default for fun and profit"
"Text"="..."
"AuthorId"="1234"

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

<b>Basic API</b>

<p style="text-align: justify;">
DynamoDB offers basic API for table creation, deletion and updating
read/write provisioning for the table. Put, get, update and delete
operations are supported for individual items. Updates can be
conditional and are can be used for optimistic concurrency control. We next look in detail the <b>Query</b> and <b>Scan</b> operations.
</p>

<b>Provisioning and Cost Calculation</b>

For each DynamoDb table we need to specify the read and the write
provisioning. Read or write unit capacity is measured as the number of
1KB items read or written per second. For example, if we provision for
5 read units for a table we can execute 100 read requests in a second
where each request read 50 bytes of data. Alternatively, only two
requests would be executed if each request reads 2Kb of data. The read
and write capacity limits the total bytes of data read or written per
second. More detail regarding calculation of read and write units can
be found <a href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/WorkingWithDDTables.html#CapacityUnitCalculations">here</a>. 



<h3><u>II) Example: A Social Blogging App</u></h3>
&nbsp;

<p style="text-align: justify;">
We want to build our hypothetical social blogging application where
people are encouraged to blog by pitting them against their friends
and give out achievements to users based on the feedback by friends.
Let us start with only two tables: Users and Posts as described above.
We will modify the above tables and add new ones as we work through
our application requirements. 

<ol>
<li>Get FacebookId given a userId. (<b>GET</b>).</li>
<li>Get friends of a user given UserId. (<b>GET</b>).</li>
<li>Get user's info given FacebookId. (<b>SCAN</b>).</li>
<li>Make two users friends. (<b>GET and PUT</b>).</li>
<li>Get all posts by a user. (<b>GET</b>).</li>
<li>Get all awards won by a user in a specific time period. (<b>QUERY</b>).</li>
<li>Get all users who won a specific award in the last two days.
(<b>SCAN</b>).</li>
<li>Get all users in a city. (<b>SCAN</b>)</li>
<li>Remove a user and all associations from our tables. (<b>SCAN</b>).</li>
</ol>

EXPLAIN ALL THE GET AND PUT CALLS. 
We first explain the scan and query operations.The cost of these
operations and then some workarounds for avoid doing scans and
reducing the overhead in many cases. 


<h3><u>III) Query and Scan Operations</u></h3>
&nbsp;

<p style="text-align: justify;">
A query operation works with a composite key where one attribute is
the hash key  and the second attribute making up the key is a range
attribute.  
</p>

<p style="text-align: justify;">
Scan operation goes through the entire table and then filters out items
not matching the criteria.
</p>

<b>Cost of Query and Scan Operations</b>



<b>Avoiding Scan Operations</b>
  1-1 mapping. 1-many and many-1. -- and code examples
<h5>Ghost Records or Application Managed Indexes</h5>

<b>Reducing the overhead of Scan Operations</b>
   1) Perform "bulk" actions with single scans.
   2) Reducing page size
   3) Isolate scan operations -- duplicate tables: "shadow tables"

<h5>If still not enough go with less performant SimpleDB which offers
query flexibility -- DynamoDB is Not the right choice </h5>

<h3>External Links</h3>

<a href="http://aws.amazon.com/dynamodb/#whentousedynamodb">DynamoDB Data Model</a>  
<a
href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/QueryAndScan.html">DynamoDB
developer guide</a>
