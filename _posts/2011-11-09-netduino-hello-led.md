---
layout: post
title: Netduino - hello led!
date: 2011-11-09 21:42:24.000000000 +02:00
categories: []
tags:
- electronic
- led
- netduino
status: publish
type: post
published: true
post_id: netduino-hello-led
meta:
  _edit_last: '1'
  _syntaxhighlighter_encoded: '1'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
Are you a .Net developer but you also dream of doing some electronic projects, like.. blinking leds? There is a app.. err.. board, for that. Netduino is the name.

![netduino]({{ site.url }}/assets/photo_overhead.gif)

I'll go on with a short description of what is it. Netduino is a small board, with a form factors same as Arduino, a very popular prototyping board. Netduino is easy to connect to the computer with a usb cable, all written software is deployed with a simple run button click. The software is written in C#, with the the .Net 4.1 Micro Framework. The new version of the Micro Framework, 4.2, has support for VB.

As for electronic features, it has 14 general purpose input-output ports. Connect LEDs to them and make them blink, or control the garage gates if you like.. 6 analog ports are handy if you want to hook up a temperature sensor, or any other thing that has an analog output. It can handle UART, SPI or I2C interfaces so you can add any other piece of electronics that needs a communication interface. Controling servo motors is easy as well with PWM.

Thirst thing I did when I got it was blinking 2 leds, the code is as follows (one is an onboard led another one I hooked to GPIO13):

    using System;
    using System.Threading;
    using Microsoft.SPOT;
    using Microsoft.SPOT.Hardware;
    using SecretLabs.NETMF.Hardware;
    using SecretLabs.NETMF.Hardware.Netduino;
    
    namespace NetduinoApplication1
    {
      public class Program
      {
        public static void Main()
        {
          OutputPort ledBlue = new OutputPort(Pins.ONBOARD_LED,
            false);
          OutputPort ledRed = new OutputPort(Pins.GPIO_PIN_D13,
            false);
          const int colorBlinkCount = 4;
          const int colorTime = 50; //ms
    
          while (true)
          {
            for (int i = 0; i < colorBlinkCount; i++)
            {
              ledBlue.Write(true);
              Thread.Sleep(colorTime);
              ledBlue.Write(false);
              Thread.Sleep(colorTime);
            }
    
            for (int i = 0; i < colorBlinkCount; i++)
            {
              ledRed.Write(true);
              Thread.Sleep(colorTime);
              ledRed.Write(false);
              Thread.Sleep(colorTime);
            }
          }
        }
    
      }
    }

And the web site <a href="http://www.netduino.com/">netduino.com</a>. A place where you can buy it with reasonable shipment price <a title="sparkfun.com" href="http://www.sparkfun.com/search/results?term=netduino&amp;what=products">sparkfun.com</a>. As you can see on the latest link, it comes in 3 flavors, the mini, the standard and pro with network capability.

.Net FTW!
