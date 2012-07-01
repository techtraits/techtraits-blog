--- 
layout: post
title: Table Design for Amazon DynamoDB
date: 2012-06-25 22:40:01
author: bilal
categories: 
- cloud
- nosql
tags:
- aws
- dynamodb
- nosql
- key-value-store
- Java
- modeling

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
  Unlike SimpleDB which has limits on request rate and total size (<b>10GB</b>) per domain, DynamoDB can theoretically be
  provisioned for infinite throughput capacity per table. This means
  that DynamoDB takes care of sharding data whereas the application is
  responsible for sharding data for SimpleDB.
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
data store that best suites your requirements. Let's take a look at
DynamoDB's data model and the QUERY and SCAN operations with some
examples to better understand the strengths and limitations of DynamoDB. 
</p>

<h3>I) Quick Intro: Data Model, API and Provisioning</h3>
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


<h3>II) Understanding Query and Scan Operations</h3>
&nbsp;

A query operation as specified in <a href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/QueryAndScan.html">DynamoDb
documentation</a>: 
<blockquote>
<p>
A query operation searches only primary key attribute values and
supports a subset of comparison operators on key attribute values to
refine the search process.
</p>
</blockquote>

and the scan operation:

<blockquote>
<p>
A scan operation scans the entire table. You can specify filters to
apply to the results to refine the values returned to you, after the
complete scan. 
</p>
</blockquote>

<p style="text-align: justify;">
A query operation uses the joint hash and range index and is available
only for tables with a composite primary key. Scan on the other hand goes through the entire
table and filter the results afterwards.
</p>

<b>Usage Examples</b>

<ol>
<li>
    <p style="text-align: justify;">Get first K versions of a post:</p>

{% highlight java %}

public Map<String, AttributeValue> getFirstKPostVersions(long postId, int k, AmazonDynamoDBClient client){
    
    Condition rangeCondition = new Condition()
        .withComparisonOperator(ComparisonOperator.LE)
        .withAttributeValueList(new AttributeValue().withN("" + k));

    QueryRequest queryRequest = new QueryRequest()
        .withTableName("Posts")
        .withHashKeyValue(new AttributeValue().withN("" + postId))
        .withRangeKeyCondition(rangeCondition);

    QueryResult result = client.query(queryRequest);
    return result.getItems();
}

{% endhighlight %}

&nbsp;
    
</li>
<li>
    <p style="text-align: justify;">Get all users in a specific city:</p>

{% highlight java %}
 public List<Map<String, AttributeValue>> getCityUsers(String city, AmazonDynamoDBClient client){
        
        List<Map<String, AttributeValue>> items = new List<Map<String, AttributeValue>>();
        Condition scanFilterCondition = new Condition()
            .withComparisonOperator(ComparisonOperator.EQ)
            .withAttributeValueList(new AttributeValue().withS(city));
        Map<String, Condition> conditions = new HashMap<String, Condition>();
        conditions.put("city", scanFilterCondition);
        
        Key lastKeyEvaluated = null;
        do {
        
            ScanRequest scanRequest = new ScanRequest()
                .withTableName("Users")
                .withScanFilter(conditions);

            ScanResult result = client.scan(scanRequest);

            for (Map<String, AttributeValue> item : result.getItems()) {
                items.add(item);
            }
        
            lastKeyEvaluated = result.getLastEvaluatedKey();
            
        }while(lastKeyEvaluated != null);
        
        return items;
  }
{% endhighlight %}
</li>
</ol>

<b>Performance and Cost Considerations</b>

<ol>
<li>
<p style="text-align: justify;"><b>Operation Speed:</b> Query operation is expected to be very fast and only marginally slower than
a get operation. The scan operation on the other hand can take
anywhere from 50-100ms to a few hours to complete and depends on the
size of the table. </p>
</li>
<li>
<p style="text-align: justify;"><b>Read Unit Cost:</b> For a query operation the read units consumed
depend on the total size of all the <b>items returned</b>. If for example, a
query operation returns 20 items with a total size of 20.1K, the read
units consumed would be 21 (assuming that the operation finishes
within a second). Since the scan operation is performed by going
through each item in the table, for any reasonable sized table the
scan operation would consume all the read units until the operation
finishes. Looking at it another way, the total time required for the
scan operation to complete can be approximated as atleast: T = S / (R * 2), where S
is the total size of the table in kilobytes and R is the read units
provisioned for a table. The reads for scan are eventually consistent
and consume half the read units as consistent reads. For a 1GB table with 100 read units
provisioned, it would take approximately 84 minutes. Note that one
scan operation would not last for that much time as DynamoDB would
only <b>evaluate</b> 1MB worth data before filtering and returning the
results. The entire table scan would therefore require 1000 scan
operations. </p>
</li>
<li>
<p style="text-align: justify;"><b>Operation Overhead:</b> Since Scan operation can consume all read units it can
slow down other operations as other operations would have to wait for
the scan operation to finish. In Section IV we look at ways to minimize
the impact of scan operations on live response-time critical operations.</p>
</li>
</ol>

When designing tables for DynamoDb we need to make sure that we don't
use any scan operations and if some scan operations are necessary take
suitable steps to isolate them and reduce the overhead on live
operations. We cover table design for performance in the following
section. 

<h3>III) Table Design for Performance</h3>
&nbsp;

<p style="text-align: justify;">
We want to build our hypothetical social blogging application
(SocBlog) where
people are encouraged to blog by peer feedback and achievements.
Let us start with a very basic data model with only two tables: Users
and Posts.</p>

<b>Basic Data Model</b>

{% highlight java %}

Users
=====
"UserId"=1234
"Name"="Bilal Sheikh"
"City"="Waterloo"

Posts
=====
"PostId"=345
"Version"=2
"DateTime"=1286751823
"Title"="Jackson Optimization, Using Non-Default for fun and profit"

{% endhighlight %}

&nbsp;


<b>Requirements</b>

<ol>
<li>
<p style="text-align: justify;">For SocBlog people would login using
Facebook only and thus we need to store the FacebookId for each
user.</p>
    <ol type="a">
        <li>Get FacebookId given a userId.</li>
        <li>Get user's info given FacebookId.</li>
    </ol>
</li>
<li>
<p style="text-align: justify;">Some user related requirements include
getting all posts by a specific user and finding out the author of
given post. </p>
    <ol type="a">
        <li>Get all posts by a user.</li>
        <li>Get the author of a post given a PostId.</li>
    </ol>
</li>
<li>
<p style="text-align: justify;">SocBlog would connect people by making
them buddies. We need to support buddy addition and removal. </p>
    <ol type="a">
        <li>Get friends of a user given UserId. (<b>GET</b>).</li>
        <li>Make two users friends. (<b>GET and PUT</b>).</li>
    </ol>
</li>

<li>
<p style="text-align: justify;">Lastly, most important features of
SocBlog have to do with posts and user search. For example, getting all new posts in
the last k days and getting all posts in a certain category.</p>
    <ol type="a">
        <li>Get all posts with more than 5 versions.</li>
        <li>Get all posts in a certain category. (<b>SCAN</b>).</li> 
        <li>Get all users in a city. (<b>SCAN</b>)</li>
        <li>Get all posts in the last K days. (<b>SCAN</b>).</li> 
    </ol>
</li>

</ol>

<p style="text-align: justify;">
We will modify the above tables and add new ones as we work through
SocBlog requirements. To deal with the first requirement, we can start by simply adding
FacebookId to Users table. This way we can easily get the FacebookId
given a UserId. 
</p>

<b>Modeling One-to-One Mappings</b>

<p style="text-align: justify;">
UserId and FacebookId have a natural one-to-one mapping. Adding the
FacebookId to the users table is not sufficient for our requirements.
Since we would need to get the UserId based on a user's FacebookId
let's say when the user signs in, this operation would still require a
complete table scan. To model this in a way to avoid table scans,
let's create a new ID table. The User table and the new ID table will
look like:
</p>


{% highlight java %}
Users
=====
"UserId"=1234
"Name"="Bilal Sheikh"
"FacebookId"="600323223"
"City"="Waterloo"

Id
==
"FacebookId"="600323223"
"UserId"=1234

{% endhighlight %}

<p style="text-align: justify;">
<ol type="a">
        <li>Get FacebookId given a userId. (<b>GET</b>).</li>
        <li>Get user's info given FacebookId. (<del>SCAN</del> <b>GET</b>).</li>
    </ol>
</li
</p>


<b>Modeling One-to-Many Mapping</b>

<p style="text-align: justify;">
UserId and FacebookId have a natural one-to-one mapping. Adding the
FacebookId to the users table is not sufficient for our requirements.
Since we would need to get the UserId based on a user's FacebookId
let's say when the user signs in, this operation would still require a
complete table scan. To model this in a way to avoid table scans,
let's create a new ID table. The User table and the new ID table will
look like:
</p>

<b>Modeling Many-to-Many Self Mapping</b>

<p style="text-align: justify;">
UserId and FacebookId have a natural one-to-one mapping. Adding the
FacebookId to the users table is not sufficient for our requirements.
Since we would need to get the UserId based on a user's FacebookId
let's say when the user signs in, this operation would still require a
complete table scan. To model this in a way to avoid table scans,
let's create a new ID table. The User table and the new ID table will
look like:
</p>


<b>Modeling Many-to-Many Mapping</b>

<p style="text-align: justify;">
UserId and FacebookId have a natural one-to-one mapping. Adding the
FacebookId to the users table is not sufficient for our requirements.
Since we would need to get the UserId based on a user's FacebookId
let's say when the user signs in, this operation would still require a
complete table scan. To model this in a way to avoid table scans,
let's create a new ID table. The User table and the new ID table will
look like:
</p>

<b>Modeling Many-to-One Mapping</b>


<p style="text-align: justify;">
Ghost records or application managed indices.
</p>

<p style="text-align: justify;">
UserId and FacebookId have a natural one-to-one mapping. Adding the
FacebookId to the users table is not sufficient for our requirements.
Since we would need to get the UserId based on a user's FacebookId
let's say when the user signs in, this operation would still require a
complete table scan. To model this in a way to avoid table scans,
let's create a new ID table. The User table and the new ID table will
look like:
</p>

<h3>IV) Minimizing Scan Operation Overhead </h3>

<b>Reducing the overhead of Scan Operations</b>
   1) Perform "bulk" actions with single scans.
   2) Reducing page size
   3) Isolate scan operations -- duplicate tables: "shadow tables"

If still not enough go with less performant SimpleDB which offers
query flexibility -- DynamoDB is Not the right choice.


<h3>V) Conclusion</h3>

<h3>External Links</h3>

<a href="http://aws.amazon.com/dynamodb/#whentousedynamodb">DynamoDB Data Model</a>  
<a href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/QueryAndScan.html">DynamoDB
developer guide</a>
