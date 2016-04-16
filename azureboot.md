---
layout: page
title: Azure Bootcamp - Service Bus Topic/Subscription
date: 2016-04-15
categories: []
tags: [service bus, azure, bootcamp]
status: publish
type: post
published: true
post_id: azure-bootcamp
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: '' 
---

### Prerequisites

- An Azure subscription
- Visual Studio 2013 or 2015
- Azure SDK

Also download the [Azure Service Bus Explorer](https://code.msdn.microsoft.com/windowsapps/Service-Bus-Explorer-f2abca5a) and extract it into a handy folder.

Next: keep focused on the hands-on.

### If you don't have an Azure account..

For today's session I've created a trial account that you can use by opening [portal.azure.com](http://portal.azure.com) and logging in with the user: clujboot@gmail.com and password: BootAzure. 

### Check-point 1

We'll create a service bus, and a topic from the Azure Portal. Then we'll configure the Topic with specific permissions for writing and reading. Lastly, we'll add subscriptions to the Topic, using Azure Service Bus Explorer.

(Hands on only!)

### Check-point 2

In this part we're going to create a very simple sender and receiver.

1. Create a solution and name it AzureSBHandsOnwith, and 2 console projects call one AzureSBSender and the other AzureSBReceiver.
2. Add the nuget packages to each project:
  - Microsoft.WindowsAzure.ConfigurationManager
  - WindowsAzure.ServiceBus
3. Update the configs. The config for the sender shuld have the Microsoft.ServiceBus.ConnectionString key set to the Topic config. The config for receiver should be set to Subscription.
4. Your Sender code should be similar to:
{% gist haiduc32/cab6f20a344fc205fa85cab85aa7cee6 AzureSBSender.cs %}
5. Your Receiver code should be similar to:
{% gist haiduc32/cab6f20a344fc205fa85cab85aa7cee6 AzureSBReceiver.cs %}

### Check-point 3

In this part we're going to enhance our sender and receiver code.

1. Your Sender code should be similar to:
{% gist haiduc32/84f3357b070af1886c2edf1d3b820e17 AzureSBSender.cs %}
2. Your Receiver code should be similar to:
{% gist haiduc32/84f3357b070af1886c2edf1d3b820e17 AzureSBSender.cs %}

### Bonus points

If we have time we'll explore more SB Topic/Subscription topics. (hands on only!)

### Further reading

[Service Bus documentation](https://azure.microsoft.com/en-us/documentation/services/service-bus/)

[Service Bus Learning Path](https://azure.microsoft.com/en-us/documentation/learning-paths/service-bus/)

