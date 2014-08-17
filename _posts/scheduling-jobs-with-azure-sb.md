---
layout: post
title: Scheduling jobs with Azure Service Bus
date: 2014-08-18
categories: []
tags: [azure service-bus]
status: publish
type: post
published: true
post_id: 11
meta:
  _edit_last: '1'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
We (me and a couple of colleagues) have been building a service that required scheduled jobs. Our initial approach was pretty straight forward: add a scheduled job and ping our website every 10 minutes to check for any jobs for that window.

It goes without saying that this is pretty stupid and totaly not recommended. But the base engine was built during 2 days of almost round the clock coding at a hackathon-like event. So it was good enough.

This scheduling mechanism has been bothering me for months but I couldn't figure out a better approach that I would actually like. Till I stumbled upon the fact that Azure Service Bus messages can be scheduled. You can place a message and specify the time you want it to be available for consumers. How awesome is that?



what does it provide:
- scalability
    we can use multiple servers/instances to process the jobs
- reliability
    if a job fails, there can be an immediate retry from the same server or another

Money!
Let's talk costs. That solution is not free. Just like most of the good things in life you have to pay for that. 

Starting October 2014, the pricing for Service Bus is changing. For this solution all you need is a Basic Tier that has no monthly charge, and it costs you 0.05$ (yes, that's zero point zero five US dollars, or read it as five cents) per 1000000 (one million) operations. There are 2592000 seconds in a month, so if you'd have a very unoptimal way to check for new messages, you'd still pay less then 15 cents a month per client.

Unless you're a total scrudge, that should be a pretty good bargain.