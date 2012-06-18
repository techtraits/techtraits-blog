--- 
layout: post
title: "Erlang: List Manipulation using comprehensions"
wordpress_id: 895
wordpress_url: http://www.techtraits.com/?p=895
date: 2012-02-11 23:06:06 +00:00
---
<p style="text-align: justify;">
I have recently started working in Erlang and there are many things to like about the language, the data isolation, the functional paradigm and the raw speed. However, one thing that no one loves about erlang is its syntax. Even after a weeks of working on the language you will still be searching through the manual to decipher what the hell does this symbol do. Since its a symbol its really hard to google the right answer unless you already know what you are looking for.</p>

<!--more-->

<h3>List comprehensions</h3>

<p style="text-align: justify;">List comprehensions are a concise way to create and modify lists in erlang using the mathematical concept of sets. Sets is math are often described using their properties and constrains in relation to other sets. For example you might describe a set as "All values of x squared such that x is in set L". Or more concisely {x*x : x in L}. The erlang code for this will be</p>

{% highlight erlang %}
L = [1,2,3,4,5]. %% define L
[X*X || X <- L].
{% endhighlight %}
&nbsp;


<p style="text-align: justify;">

We can even put constraints on the values of the original set that will be used in the new set construction. For example lets say our definition now is "All values of x squared such that x is an even number in the set L". The erlang code for this is:</p>

{% highlight erlang %}
L = [1,2,3,4,5]. %% define L
[X*X || X <- L, X rem 2 =:= 0].
{% endhighlight %}
&nbsp;



<p style="text-align: justify;">

Lastly we can even use multiple sets as inputs to a list comprehension call. For example a list defines as "All values of x multiplied by y such that x is an even number in the set L and y is an odd number is set S". The code for this will be as follows:</p>

{% highlight erlang %}
L = [1,2,3,4,5]. %% define L
S = [6,7,8,9,10]. %% define S
[X*X || X <- L, Y <- S, X rem 2 =:= 0, Y rem 2 =:= 1].
{% endhighlight %}
&nbsp;

<h3>External links</h3>

* [Learn you some erlang](http://learnyousomeerlang.com/starting-out-for-real#list-comprehensions)
* [Erlang Programming](http://en.wikibooks.org/wiki/Erlang_Programming/List_Comprehensions)
* [Erlang Docs](http://www.erlang.org/doc/programming_examples/list_comprehensions.html) 

<h3>Key words for the weary googler</h3>

So in the interests of googlers here are some key words that you might search for.

* What does "||" do in erlang.
* What does "[||]" do in erlang.
* Erlang Double Pipe


