---
layout: post
title: ESP8266, Arduino & Azure IoT Hub
date: 2016-04-03
categories: []
tags: [esp8266, arduino, azure iot hub]
status: publish
type: post
published: true
post_id: esp8266-arduino-iot-hub
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: '' 
---
IoT is all the trend and I do like to play with small devices that you can connect to the internet. Lately I am playing with a pet project where I need to send commands from my service hosted in the cloud to the devices that can be anywhere. And for that Azure IoT Hub comes in handy. I won't go into what it is and how to use it (maybe in another article) but I wanted to explain how to setup your ESP8266 with arduino to connect and listen for messages, as people are having a hard time doing that.

Before you get to reading this article, you must have a working example in C#, node.js, java or anything else. Otherwise if it doesn't work you won't be able put your finger on where the problem is. Please read this first if you haven't already:

- [Setting Up Azure IoT](http://thinglabs.io/workshop/cs/nightlight/setup-azure-iot-hub/)
- [IoT Hub MQTT support](https://azure.microsoft.com/en-us/documentation/articles/iot-hub-mqtt-support/)
- [How to use Device Explorer for IoT Hub devices](https://github.com/Azure/azure-iot-sdks/blob/master/tools/DeviceExplorer/doc/how_to_use_device_explorer.md)
- [Azure IoT Hub developer guide](https://azure.microsoft.com/en-us/documentation/articles/iot-hub-devguide/)

I will presume you have enough knowledge of Arduino and ESP8266 and will jump to the important parts.

First, you need a library to connect to the IoT hub. For small devices your (kind of) only option is to use the MQTT protocol. The [PubSubClient][] library comes in handy. There are forks with newer version, and you can try them out but I recommend you first try working with this one as it is proven to be working with the Azure IoT Hub.

You can get started by going to the examples folder, and picking the ESP8266 one. Note that you must copy the PubSubClieent source files in the same folder as your ino, or in a library folder.

Now let's get to "fixing" the PubSubClient library.. because the Azure IoT Hub password is so long, you must go into the .h file, find the line `#define MQTT_MAX_PACKET_SIZE 128` and put a bigger number, like 256. 256 worked for me. If you need big messages you probably need to put a bigger number, but that would mean you're probably doing something wrong.

Time to start editing the ino file. 

Find the line with `const char* mqtt_server = "broker.mqtt-dashboard.com";` and set the address to something like `<myhubname>.azure-devices.net` where `<myhubname>` is the name you gave to your IoT Hub when you created it from Azure dashboard.

Find the line with `WiFiClient espClient;` and replace the type with WifiClientSecure. You need this because Azure IoT Hub is using TLS. You might need to add `#include <WiFiClientSecure.h>` in order to compile. (the provided sample doesn't have an include for WiFiClient, but I found that you need it).

Next, on the line with `if (client.connect("ESP8266Client")) {` we need connect with authentication, so that'll be `if (client.connect(<deviceid>, <hubuser>, <hubpass>)) {`. Now to explaining what exactly you need to pass:

- `<deviceid>` - is the name you gave to your device when you registered. If you follow the Setting Up Azure IoT tutorial, that'll be ThingLabs00.
- `<hubuser>` - that is constructed in the form of `<myhubname>.azure-devices.net/<deviceid>` - just replace the values.
- `<hubpass>` - now that's a bit tricky.. you can construct the SAS key on your ESP8266, but that's quite some work and I won't go into that. The easiest way to get a pass is to use the Device Explorer to generate a key for 365 days (for ex.) Go to Device Explorer on the Management tab, click the device and the "SAS Token.." button. Set the number of days and hit Generate. Now select the part `SharedAccessSignature sr=....qnlvs%2bERTKS3qqvO0T7cRG2D1xhI7PiE5C8uk%3d&se=1490896187`. That's your hubpass. Easy, right?

And we're almost ready.. 
In order to receive messages you have to subscribe to the proper topic. Find the line `client.subscribe("inTopic");` and replace with `client.subscribe("devices/<deviceid>/messages/devicebound/#");`. To send messages from device to cloud send them on the `devices/<deviceid>/messages/events/` so that the line with `client.publish("outTopic", "hello world");` becomes `client.publish("devices/<deviceid>/messages/events/", "hello world");`

Now you should be in the position to witness the magic of IoT Hubs, connecting your devices to the cloud. 

**Afterthoughts** Security! Security! Security! If you want to do more than just blink some leds, you probably should think about setting the TLS properly. The sketch has no certificate validation, so anyone can impersonate the Azure IoT Hub and intercept all the traffic, or issue messages to your device. So that's one. Second, SAS token is best to be constructed inside your sketch, then asking your service (whatever api you're building) for a newer token every x (put a measure of time in here). Yes, that's not that easy, and you'll need to get the time, hash the string and Base64 it (there are arduino libraries out there).

Drop a comment, a question or share it with the world ;)