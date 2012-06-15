--- 
layout: post
title: Using cachedump to debug memcached
wordpress_id: 451
wordpress_url: http://www.techtraits.ca/?p=451
date: 2011-10-02 22:23:27 +00:00
---
<p style="text-align: justify;">
If you are using <a href="http://http://memcached.org/" title="memcached" target="_blank">memcahced</a> for caching it will be is sometimes necessary to check the state of the cache. There is no way to dump all keys stored in a memcached server but using cache dump we can retrieve about a megabyte of data which is often sufficient for debugging.
<!--more-->
To retrieve the keys first telnet to your server:
<pre lang="bash">
telnet localhost 11211
</pre>

Use the stats command to get stats about the different slabs of keys in your server. The number after "items:" is a slab id and memecached will store your stats in several slabs. 

<pre lang="bash">
stats items
STAT items:1:number 1
STAT items:1:age 3430476
STAT items:1:evicted 0
STAT items:1:evicted_nonzero 0
STAT items:1:evicted_time 0
STAT items:1:outofmemory 0
STAT items:1:tailrepairs 0
STAT items:1:reclaimed 113
STAT items:2:number 4
STAT items:2:age 555952
STAT items:2:evicted 0
STAT items:2:evicted_nonzero 0
STAT items:2:evicted_time 0
STAT items:2:outofmemory 0
STAT items:2:tailrepairs 0
STAT items:2:reclaimed 12
STAT items:3:number 4
STAT items:3:age 2894457
STAT items:3:evicted 0
STAT items:3:evicted_nonzero 0
STAT items:3:evicted_time 0
STAT items:3:outofmemory 0
STAT items:3:tailrepairs 0
STAT items:3:reclaimed 4
STAT items:4:number 2
STAT items:4:age 3411747
STAT items:4:evicted 0
STAT items:4:evicted_nonzero 0
STAT items:4:evicted_time 0
STAT items:4:outofmemory 0
STAT items:4:tailrepairs 0
STAT items:4:reclaimed 9
STAT items:8:number 18
STAT items:8:age 1330321
STAT items:8:evicted 0
STAT items:8:evicted_nonzero 0
STAT items:8:evicted_time 0
STAT items:8:outofmemory 0
STAT items:8:tailrepairs 0
STAT items:8:reclaimed 1
STAT items:10:number 11
STAT items:10:age 3238392
STAT items:10:evicted 0
STAT items:10:evicted_nonzero 0
STAT items:10:evicted_time 0
STAT items:10:outofmemory 0
STAT items:10:tailrepairs 0
STAT items:10:reclaimed 0
END
</pre>

To get the keys stored in each slab use the cachedump command. In the command shown below we are retrieving a maximum of hundred keys from the 4th slab.
<pre lang="bash">
stats cachedump 4 100 
</pre>

That's it, happy debugging. 
