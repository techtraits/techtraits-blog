---
layout: page
title: Tech Traits
tagline: Think big, Its free.
---
{% include JB/setup %}


{% for post in site.posts limit:5 %}
<h3><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h3>
{% assign author = site.authors[post.author] %}
<span class="author">by <a href="/{{ author.name }}.html"><strong>{{ author.display_name }}</a></strong> on <span>{{ post.date | date_to_string }}</span>

{{ post.content | strip_html | truncatewords: 100 }} <a href="{{ BASE_PATH }}{{ post.url }}">more</a>
 
{% endfor %}




