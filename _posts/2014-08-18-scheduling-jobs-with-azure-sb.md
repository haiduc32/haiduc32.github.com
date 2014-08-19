---
layout: post
title: Scheduling jobs with Azure Service Bus
date: 2014-08-20
categories: []
tags: [Azure, Service Bus]
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

It goes without saying that this is pretty stupid and totally not recommended. But the base engine was built during 2 days of almost round the clock coding at a hackathon-like event. So it was good enough.

This scheduling mechanism has been bothering me for months but I couldn't figure out a better approach that I would actually like. Till I stumbled upon the fact that Azure Service Bus messages can be scheduled. You can place a message and specify the time you want it to be available for consumers. How awesome is that?

### Solution design
Let's see two common usages of scheduled jobs:

- You have a website that checks every 10 minutes for pending data to be processed. You'll need some external scheduler to call a specific page that does the processing. Lot's of things can go wrong here..
- You have a website that puts data in the database. You' back-end service checks in every 10 minutes and processes that data. Now that's better because you're not concerned that your IIS will reset the process in the middle of processing, but it's still pretty clumsy.

What I want to be able to do:

- Start processing a job immediately as it is available.
- Have multiple back-end services that can process the jobs so I can be able to scale and have a redundancy in case one server goes down.
- Make the job processing more resilient. If a server breaks during processing of a job, I want another one picking it up.

You can do all that with a classic scheduler model, interrogating the database/website every second, building a lot of synchronization stuff, and preying. But I'd rather use a simple and elegant solution that Azure Service Bus can provide.

Here is a simple diagram that shows all the parts of the solution: the users, the website, the Azure Service Bus Queue and the back-end service. (By the way, I recommend using [Draw.io](http://draw.io) for creating simple diagrams fast.)

![Azure Service Bus Job Scheduling]({{ site.url }}/assets/AzureJobScheduling.png)

You can have on back-end service or more, or you can integrate it into your website if you have the option of keeping your website always on. This solution leaves this option up to you.

All you need to do is go into Azure, create a Queue in a new Service Bus or in an existing Service Bus, add the code to put messages on the Queue and the code to read them. How to create the Azure Service Bus Queue is explained pretty good [here](http://azure.microsoft.com/en-us/documentation/articles/service-bus-dotnet-how-to-use-queues/ "How to Use Service Bus Queues").

### Stop talking, show me the code!
Right, so you're interested.. If you're not familiar with the Azure Service Bus Queues you should start by ready some documentation and samples before trying to understand the code examples. As mentioned earlier, a good place to start is [here](http://azure.microsoft.com/en-us/documentation/articles/service-bus-dotnet-how-to-use-queues/ "How to Use Service Bus Queues").

Here is an example of putting a message on the Service Bus Queue. Note: it depends on the Json.NET package (just NuGet it). Most of the code should be self-explanatory.

{% gist haiduc32/d3d5e86eaf5eb30e72e4 SBSchedulingSend.cs %}

Notice that trick with the "Type". That way I don't need another parameter to the method. When I receive the message I just check the Type and send it to the appropriate method to be processed.

Now the part where you wait for the messages

{% gist haiduc32/d3d5e86eaf5eb30e72e4 SBSchedulingListen.cs %}

By calling the Listen() method you wait for any messages on the Service Bus Queue. Once one is available it will immediately be processed by the MessageHandler(). It's important to mark the message as complete once the job has been processed. 

You can also  DeadLetter it, if it's an invalid message, or there is an unrecoverable error. That will put the message in a special Queue with all the dead messages, and no other client will receive it again. You can read them later for debugging if needed.

Another option is to Abandon the message. That will put the message back on the Queue for anyone to read it. The client that abandoned the message might receive it again, so watch out. You might want to abandon a message if you suddenly figure out that you don't have resources to process it, hopping that other service will pick it up.

### Challenges
It's not just pink unicorns. While you loose the scheduler, and have a more granular and focused job scheduling, there are aspects you must keep in mind when designing your scheduler.

Once you put a message on the Service Bus, you can't take it back! If you put a message that tells your home automation system to start the Toaster at 6:30AM, you can't cancel that message. 

You must have a mechanism to check that the message is still valid. Most of the time your message will be linked to some data in the database. What you can do is keep a *Version* column, that changes every time you make an update. The message you place on the Service Bus should also contain that *Version*. You should also place a new message with every change. When you process the message, if the *Version* from the message is not the same as from the database, you should ignore it.

The other challenge you should be aware of is the Lock Duration. When you create the Queue, you can specify the Lock Duration for the messages. You can't set more than 5 minutes. That means you must process a job in maximum 5 minutes and mark it as Complete(), or you must RenewLock() before that Lock expires.

### Money!
Let's talk costs. That solution is not free. Just like most of the good things in life you have to pay for that. 

Starting October 2014, the pricing for Service Bus is changing. For this solution all you need is a Basic Tier that has no monthly charge, and it costs you 0.05$ (yes, that's zero point zero five US dollars, or read it as five cents) per 1000000 (one million) operations. There are 2592000 seconds in a month, so if you'd have a very suboptimal way to check for new messages, you'd still pay less than 15 cents a month per client.

Unless you're a total scrooge, that should be a pretty good bargain.
