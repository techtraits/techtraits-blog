---
layout: page
---

{% include JB/setup %}


{% for post in site.posts offset:0 limit:5 %}

{% assign author = site.authors[post.author] %}

<div class="meta">
<h3><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h3>

<span class="author"> by 
    <a href="/{{ author.name}}.html">
        <strong>{{author.display_name }}</strong>
    </a> on {{post.date | date_to_string }}
</span>

<p></p>
<p>
{{ post.content | strip_html | truncatewords: 100 }} 
<a href="{{BASE_PATH }}{{ post.url }}">more</a>
</p>
</div>

{% endfor %}







