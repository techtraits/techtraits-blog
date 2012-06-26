--- 
layout: post
title: Amazon DynamoDB&#58; Introduction to Query and Scan operations
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
key-value store used internally for amazon.com's product cart.  

DynamoDB offers two main advantages over SimpleDB (Amazon's initial
NoSQL offering based on Google's <a href="http://static.googleusercontent.com/external_content/untrusted_dlcp/research.google.com/en//archive/bigtable-osdi06.pdf">BigTable</a>):

<ul>
  <li>
  Unlike SimpleDB which has hard request rate limits (<b>70
  requests/sec</b>) per domain, DynamoDB can theoretically be provisioned for infinite throughput capacity per domain. This means
  that the application does not need to shard data into multiple domains to work around the throughput limits.
  </li>
  <li>
  Second, DynamoDB offers faster and more predictable query performance, mainly because of
  restricted data model and the use of faster solid state drives.
  </li>
</ul>

</p>

