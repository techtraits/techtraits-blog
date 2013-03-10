--- 
layout: post
title: Tips on building a Game as a service (the service parts)
date: 2013-03-10 11:29:21
authors:
- usman
categories: 
- System Design
tags:
- games
permalink: /gas.html

---
Seth Sivak recently wrote an [article](http://www.gamasutra.com/blogs/SethSivak/20130305/187766/The_Future_of_Games_as_a_Service.php) covering some tips on how to design games as a service. While this article covers the game design side of making games as a service there is an equally import part, the Service design. As a member of EA's casual games' server engineering organization I have been part of and spectator to a number of social/casual game launches, some of which were a success and some of which were catastrophic failures.(From a service point of view). This article covers a few of the lessons learned and the major pitfalls from titles such as [The Simpsons Tapped Out](https://play.google.com/store/apps/details?id=com.ea.game.simpsons4_row&hl=en), [World Series of Poker](https://itunes.apple.com/us/app/world-series-of-poker/id458792705?mt=8), [Scrabble](https://itunes.apple.com/ca/app/scrabble/id284815117?mt=8) and [The Sims Social](https://www.facebook.com/TheSimsSocial).


# Beware of the BLOB that ate everything
&nbsp;
Unfortunately, BLOBs (Binary Large Objects) are very common in game servers. There is a preception loading one large object over the network is faster than loading lots of small objects. This is true if you load them one at a time but modern smartphones and browsers can issue all requests in parallel.  The Simpsons Tapped Out uses BLOBs to store players' Springfields and  The Sims Social used them to store your home. Both those games had significant server stability issues that were exacerbated if not caused by the use of blobs (See [Here]((http://www.modojo.com/features/the_simpsons_tapped_out_trouble_in_springfield)) and [Here](http://blog.games.com/2011/08/09/the-sims-social-already-suffering-from-connection-problems/)). 

The first problem with blobs is that you are putting all your eggs in one basket, if the blob gets corrupted you are dead in the water. This was seen in both the Simpsons and the sims social where a server bug caused some Springfields and Sims' homes to get mangled after which point the game would be unplayable for that user. If instead the server had stored data smaller subject specific objects the damage would have been more limited. If I take the Simpsons as an example rather than having one massive Springfield object the data should have been something like; User Level, Doughnut Balances, the buildings built, the characters unlocked, on going actions. This way if any one of those objects (Kwik-E-Mart) gets mangled the game can continue Irate users can complain to customer service and be given free doughnuts. What instead happened was that Simpsons was unplayable for months and had to be pulled from the App Store.

The second problem with BLOBs is that they are usually big and tend to grow over time. This means sooner or later you are going start hitting limits such as the max size of objects in data stores, the size of objects in cache. This is what happened to the Sims Social launch where the hose BLOB size exceeded the limit of a storage system and subsequently the effected users were unable to play. Also bigger objects take longer to transfer over the network and hence are more likely to be corrupted in transfer specially if the game is on smartphone over the cellular network. The bigger objects also consume a lot more server memory during processing hence its more difficult to scale out. Both of these issues were seen on the simpsons where the servers were unable to cope with the load and truncated network communication would cause land corruption.  

Thirdly, blobs break the seperation of concerns design pattern. One blob has data for all sorts of different features of the game. Hence it is touched by developers working on all those different features, a bug in any one of the features can cause problems in the blob and foobar your game. Where as with smaller objects the bug should take out a smaller portion of your game. 

Finally, for any social casual game you will probably start of with write one read many semantics. I.e. The owner of the BLOB can update it (i.e. put a Kwik-E-Mart on their Springfield) but her friends can come and view it springfield only. However, sooner or later you will require a feature where you need a friend to be able to update a feature on your object, i.e. Farmville get your friends to harvest your crops etc. At this point you will now have to deal with concurrent updates to the same object. You have to make sure that both updates are atomic, consistent and allowed by the game play rules. With a single huge BLOB concurrent updates are much more likely and difficult to resolve. 



# Sticky sessions are gross

The next mistake that a lot of game engineers make when designing servers is using sticky sessions unnecessarily. If you game is a real time multiplayer game you need sticky sessions otherwise you should avoid them at all costs. Sticky sessions are tempting because all the data needed for the user will already be on the server, you can segment your traffic into independent sets of users and provision resources such as database shards accordingly. When users actually start playing all your predictions about how they will behave go out of the window. They will put too much load on your server as seen in the current Simcity launch among others, or they will stop playing leaving you with lots of empty servers with very few users as seen in Star Wars the Old republic. They will cram too much useless stuff into their houses/lands which will make all your infrastructure planning regarding DB nodes per user-shard invalid. In addition servers will go down, be slow randomly for no apparent reason. For all these reasons if you have cursed a user to go to the same server and said server is unresponsive or slow you have just ruined that users experience for good. Instead if you allow each of the users to go to any server in your array then the game play sessions not as vulnerable to random failure. If a server is slow the user will naturally shut the game down and login again. If you have hundreds of servers chances of hitting the same slow server are very remote. Once you notice that one or more servers are not responding properly you can just such them down without having to consider user migration. If you get a massive influx of users you just have to launch a few more servers, no worrying about how to re-shard databases, re-balance users per server. 

# Monitor all the things 

I am not even going to write much here this has been covered well in a lot of articles including [here](http://codeascraft.etsy.com/2011/02/15/measure-anything-measure-everything/) and [here](http://www.youtube.com/watch?v=czes-oa0yik). I have been called onto fire-fighting efforts multiple times when games were having problems at launch including Simpsons and Scrabble and the first thing I always notice is that there is little or no monitoring. There are a plethora of monitoring and reporting tools out there and there is really no excuse not to monitor every little thing about your server specially, size of all objects, response times, response times for calls out from the server, cache and data sizes, cache miss ratios, and exception rates. 


# Let the user play


This is another one of those problems that I see frequently in game servers and am baffled by the design decisions that led to them. Most games in the casual social genre are mostly client side: the user clicks a few things which has an impact on the state of her object(s) and said objects are saved to the server. If the service happens to be down the the client should cache the update and try again when the service is up again. I get that an online multi-player game cannot function without servers but there is no excuse as to why Simcity, Simpsons, Sims Social or any such game needs to catastrophically die if the server is unreachable. 

# Can you bring it up now

When I have been called to fire-fight a launch that is going wrong often my first question is why aren't you bringing up more servers to handle the load. Sadly, the answer all to often is "We email IT to do it they will do so within 24 hours" or "We are ordering more hardware" or in the case of database nodes "Our license only allows N nodes". In this day and age any half decent server team needs to be able to bring server instances up (or down) in minutes. This requires a few things firstly cloud support. There are very few reasons use your own hardware instead of a cloud-based service provider. However, even if you do go the route having your own hardware  your services should be architected to be able to being up extra nodes one the cloud. Zynga's [z-cloud](http://code.zynga.com/2012/02/the-evolution-of-zcloud/) is an excellent example of this.  When their own infrastructure is not able to serve demand they can switch seamlessly to Amazon Ec2 instances. If you do not have the resources to build such an hybrid system them put all your nodes in ec2. The cloud being more expensive is or unreliable is a myth when you factor in the cost and complexity of maintaining infrastructure at scale. 


# Know your limits and what to do about it

Regardless of whether you are on the cloud or not nothing scales infinitely. You should know the limits of your scaling and the bottlenecks. Amazon Simple DB cannot have more than 10GB per domain, and cannot have more than 256 attributes per item. On google App Engine you can only do 46 million URL Fetch calls per day (on the paid tier). Some of these limits may seem so high as to be ignored but that is dangerous thinking. For the Simpsons android launch we used the Google Identity Service to sign auth tokens. We found that we are only allowed 1.84 million calls to this API. When we launched worldwide we were hitting this limit repeatedly. 

The first step in this regard is to load test extensively, figure out what the pain points are and more importantly how the various infrastructure pieces relate to each other. In the Simpsons launch we ran into issues where we had enough server capacity but the load balancer was not able to keep up with traffic hence more instances were useless. Similarly, Scrabble had a very Oracle based data store but when it reached capacity launching more web nodes was pointless. On world series of poker we found that we needed 1 stateless user management server for about 3000 clients, but we needed 3 memcached servers  and 2 state-full table server for the same load. 

The next step is to always have a plan on what to do if limit start getting hit. This does not mean you should do anything about if the limit really is very large for your needs but keep it in mind. With Amazon Simple DB be prepared to shard across domains by keeping a generic wrapper over the calls so that you can implement shading without changing business logic code. In case URL Fetch APIs limitation ask Google  if that limit can be increased if you hit it. Figure out how many cache nodes you need and what happens when you need more? Will you need to bring down the game to launch more cache nodes? Is that acceptable to game producers? If not you may want to over provision cache at the start to begin with. 


# Conclusion

None of the steps I have talked about are particularly ground breaking or new to Server engineers but for some reasons not well understood in the game server design community. The days where we would work on a game for months and years, launch and be done with it are long gone. Now you have to realize you will be supporting the servers for the game years after its launch. Therefor it pays to put as much thought and effort into server design as you would into gameplay. 

Disclaimer:
The views expressed on these pages are mine alone and not those of my employer.