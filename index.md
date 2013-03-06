---
layout: page
---

{% include JB/setup %}


{% for post in site.posts offset:0 limit:5 %}

<div class="meta">
<h3><a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></h3>

<span class="author"> by 
	<strong>
		{% for author in post.authors %}
    		<a href="/{{ site.authors[author].name}}.html">
        		{{site.authors[author].display_name }}
	        </a>
			{% if forloop.first and forloop.length > 1%}
			 & 
			{% endif %}
    	{% endfor %}
    </strong>
     on {{post.date | date_to_string }}
</span>

<p></p>
<p>
{{ post.content | strip_html | truncatewords: 100 }} 
<a href="{{BASE_PATH }}{{ post.url }}">more</a>
</p>
</div>

{% endfor %}







