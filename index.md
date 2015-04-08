---
layout: page
---
{% include JB/setup %}

<div class="blog-index">  
  {% assign post = site.posts.first %}
  {% assign content = post.content %}
    <h1 class="entry-title">
    {% if page.title %}
        <a href="{{ root_url }}{{ page.url }}">Latest: {{ page.title }}</a>
    {% endif %}
    {% if post.title %}

        <a href="{{ root_url }}{{ post.url }}">Latest: {{ post.title }}</a>
    {% endif %}
    </h1>
    
    <div class="content">{{ content }}</div>
        <div class="post-sharing">

      <script type="text/javascript" src="//s7.addthis.com/js/300/addthis_widget.js#pubid=ra-53f4eb4678c482ba"></script>

      <div class="addthis_sharing_toolbox" data-url="{{ HOME_PATH }}{{ post.url }}" data-title="{{ post.title }}"></div>
    </div>
    {% include JB/comments %}

</div>


    
## Blog Archive

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

