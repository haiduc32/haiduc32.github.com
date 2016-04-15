---
layout: post
title: Fancy Words I
date: 2015-06-25
categories: []
tags: []
status: draft
type: post
published: false
post_id: fancy-words
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''  
---
When was the last time you were in a meeting with the client and they said they wanted blue-green deployment, or a white label solution (replace with any other concept that isn't familiar to you)?

It happens all the time, someone comes with a new terminology that you aren't familiar with and for not wanting to look dumb you try to google the unknown terminology, in a sneaky way so the client wouldn't figure you out. We've all been there.

So here's a list of 20 concepts that you should know of (in no particular order, click on it for more details):

- TDD - Test driven development, as in write tests first.
- BDD - Behaviour driven development. Similar to TDD but different. 
- Aspect Oriented Programming (AOP) - wow.. just click on the link.
- Convention over configuration - simplest example - if you have a class with Controller suffix, it will be auto injected, and you don't have to do any configurations for that.
- Snail mail - ordinary mail, you know.. like in the good old days.

### Intro (or the part you skip if you're in a hurry)
If you ever wrote a decent piece of application I bet you added form of logging. There is no enterprise application that doesn't have extensive logs.
Now the problem with classic logs is it's written to files. The files are kept with the applications, or at least on the same machine as the application. If you have a distributed environment you, most likely, have distributed log files. 
And I'm not even scratching the surface here.. the files aren't easy to handle when you need to search where a certain error has happen, or debug why you didn't get the response to your query, or who knows what scenario you have to solve.

As for my own context and pain: working on a complex enterprise system there are a lot of components involved in getting data synchronised from one system to another and there are many points of failure. Even on the development environment, getting the logs and analysing them is a pain. 
For quite some time I was tinkering with the idea to centralise all the logs somewhere somehow. And there are quite a few services that can do the job, but I needed a solution that could work on premisses with no external access and also for the cloud components. There were also some security concerns so using cloud based services was not an option.

### Getting to the point
I stumbled over the [ELK](https://www.elastic.co/) ([Elasticsearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash), [Kibana](https://www.elastic.co/products/kibana)) stack when I was looking for solutions for logging 