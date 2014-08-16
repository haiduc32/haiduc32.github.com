---
layout: page
title: Welcome
---
{% include JB/setup %}

I've migrated my blog from blog.cyberkinetx.com to this new place. Unfortunately the migration wasn't that smooth and the old posts lack formatting, images and comments. I'll be trying to re-format, and re-import the images as I find time, but for the comments.. there's nothing to be done here.

I'm still struggling with this new thingie (Jekyll and github.io). Looks like it's the new fashion to build blogs on github and since I'm tired of hosting Wordpress on my home pc, and solving domain problems with IP resets, I decided to give it a go.

Lots of work to be done to get this place to look like a.. blog. 

    
## Blog Archive

<ul class="posts">
  {% for post in site.posts %}
    <li><span>{{ post.date | date_to_string }}</span> &raquo; <a href="{{ BASE_PATH }}{{ post.url }}">{{ post.title }}</a></li>
  {% endfor %}
</ul>

