---
layout: post
title: Centralizing your logs
date: 2015-04-07
categories: []
tags: [Azure, Service Bus]
status: publish
type: post
published: true
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''  
---
### Intro (or the part you skip if you're in a hurry)
If you ever wrote a decent piece of application I bet you added form of logging. There is no enterprise application that doesn't have extensive logs.
Now the problem with classic logs is it's written to files. The files are kept with the applications, or at least on the same machine as the application. If you have a distributed environment you, most likely, have distributed log files. 
And I'm not even scratching the surface here.. the files aren't easy to handle when you need to search where a certain error has happen, or debug why you didn't get the response to your query, or who knows what scenario you have to solve.

As for my own context and pain: working on a complex enterprise system there are a lot of components involved in getting data synchronised from one system to another and there are many points of failure. Even on the development environment, getting the logs and analysing them is a pain. 
For quite some time I was tinkering with the idea to centralise all the logs somewhere somehow. And there are quite a few services that can do the job, but I needed a solution that could work on premisses with no external access and also for the cloud components. There were also some security concerns so using cloud based services was not an option.

### Getting to the point
I stumbled over the [ELK](https://www.elastic.co/) ([Elasticsearch](https://www.elastic.co/products/elasticsearch), [Logstash](https://www.elastic.co/products/logstash), [Kibana](https://www.elastic.co/products/kibana)) stack when I was looking for solutions for logging into 3rd party services, something that I was investigating for one of my projects. But after a bit of research it proved like the best way to get my logs from multiple applications and servers in a single place, and also have the benefit of searching, filtering and building some simple BI.

So what is it exactly? Let me make a fast breakdown:

 - Logstash has the responsibility of getting log files, parsing them into JSON data and sending it into the Elasticsearch database. Logstash can act also as a TCP client (that's what I used) and parse the incoming stream.
 - Elasticsearch is a document db. It stores unstructured JSON files and can do full text searches and all kind of stuff I'm not even aware of. People claim it to be pretty fast.
 - Kibana is a UI for the Elasticsearch. You can use it to define search filters, format the data, group it, build charts. Some simple BI can be done with it.

### My setup
My plan was to use a custom target with the NLog to push all logs to the Azure ServiceBus, and to have a component listening for those and pushing them to logstash, that would parse the log as json and it into the Elasticsearch database, and ultimately, use Kibana to view, search, filter the logs.
I got the whole setup working in a day (given that I had to write the nlog target and the ServiceBus listener).
So that would work well for applications that are deployed in the cloud. As for the on premise applications, the ServiceBus part can be skipped since the logstash can liste on the TCP, and NLog has built in TCP target.

### The good, the bad and the ugly
Taking a few lines to summarise the good and the bad. The good first:

 - Easy to get running, doesn't require install, just extract the archived files and you're good to go. Works on Linux, Mac and Windows.
 - The interface is pretty simple to use, doesn't give you lots of options..
 - Building charts and some limited Business Inteligence
 - Seems pretty fast

The bad:

 - The Kibana UI. I mentioned in the good section that the interface is simple, but it's not spartan, so I'd expect some basic options to be available like choosing the colors for the charts (imagine you want to set a bar charts with errors per hour, default color is green, not the best color for errors)
 - I couldn't get the logstash part to run as a windows service, but maybe it's just me..
 - All the components are developed with different programming languages. Not best scenario if you want to tinker with them
 - If you want user authentication and authorisation you have to install Shield which is a payed product for production

### Wrapping it up
If you need to get centralised logs fast and cheap, the ELK stack seems like the best choice by far. There are service online that offer a free subscription, but what you get is not worth the effort of signing up.

What's missing from the ELK stack is a tool to send notifications based on some triggers. For example on certains errors, to send emails to the support team. Aggregating errors and sending to developers for analysis, etc. I've been thinking on that and maybe some kind of tool could be coming up some time in the future.

My near future plans are to publish on Github the nlog target, log4net appender, and the LogstashAdapter (the part that listens on the ServiceBus and pushes the logs to logstash). That should happen in the next couple of weeks so stay tuned ;)