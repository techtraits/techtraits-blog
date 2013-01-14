--- 
layout: post
title: DynamoDB&#58; Modeling Data for Performance
date: 2012-06-28 12:00:00
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
We want to build our hypothetical social blogging application
(SocBlog) where people are encouraged to blog by peer feedback and achievements. Let us start with a very basic data model with only two tables: Users
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
