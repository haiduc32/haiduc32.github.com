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

Also download the [Azure Service Bus Explorer](https://code.msdn.microsoft.com/windowsapps/Service-Bus-Explorer-f2abca5a) and extract it to a handy folder.

Next: keep focused on the hands-on.

### Check-point 1

We'll create a service bus, and a topic from the Azure Portal. Then we'll configure the Topic with specific permissions for writing and reading. Lastly, we'll add subscriptions to the Topic, using Azure Service Bus Explorer.


### Check-point 2

In this part we're going to create a very simple sender and receiver.

1. Create a solution and name it AzureSBHandsOnwith, and 2 console projects call one AzureSBSender and the other AzureSBReceiver.
2. Add the nuget packages to each project:
  - Microsoft.WindowsAzure.ConfigurationManager
  - WindowsAzure.ServiceBus
3. 