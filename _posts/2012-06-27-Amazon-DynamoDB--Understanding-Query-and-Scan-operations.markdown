--- 
layout: post
title: DynamoDB&#58; Understanding Query and Scan Operations
date: 2012-06-27 20:20:05
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
table and then filters the results afterwards.
</p>

<b>Usage Examples</b>

Assume that we have a Users table and a Posts table which look like:

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
through each item in the table, for any reasonably sized table the
scan operation will consume all the read units until the operation
finishes. Looking at it another way, the total time required for the
scan operation to complete can be approximated as atleast: T = S / (R * 2), where S
is the total size of the table in kilobytes and R is the read units
provisioned for a table. The reads for scan are eventually consistent
and consume half the read units compared to consistent reads. For a 1GB table with a provisioning of 100 read units, it would take approximately 84 minutes. Note that one scan operation wouldn't last 84 minutes because DynamoDB will only evaluate <b>1MB</b> worth of data before filtering and returning the
results. The entire table scan would therefore require 1000 scan
operations. </p>
</li>
<li>
<p style="text-align: justify;"><b>Operation Overhead:</b> Since a scan operation can consume all read units, it can
slow down other operations by starving them.</p>

</li>
</ol>

When modeling data for DynamoDB, one must try to minimize any potential scan operations. Designing tables for performance and ways to minimize the impact of scan operations is covered in my next post: <a href="#">DynamoDB: Modeling data for performance</a>

<h3>External Links</h3>

<a href="http://docs.amazonwebservices.com/amazondynamodb/latest/developerguide/QueryAndScan.html">DynamoDB
developer guide</a>
