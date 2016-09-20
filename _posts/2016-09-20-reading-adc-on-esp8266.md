---
layout: post
title: Reading the ADC on ESP8266
date: 2016-09-20
categories: []
tags: [esp8266, Arduino]
status: publish
type: post
published: true
post_id: reading-adc-on-esp8266
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: '' 
---
If you've been playing with the ESP8266 WiFi Module you know how awesome it is. I've done a couple of hobby projects with it and now it's my go-to platform combined with Arduino.

My latest project is a thermostat and it gave me some headache when trying to read the temperature sensor value over ADC. When reading the sensor value I was getting a spread of 1-2 deg. Celsius from one read to another in one second intervals. Even when trying to apply filters it will not go down. Initially I thought it's the sensor as the datasheet was saying that it should have a 0.5 spread, and maybe it was low quality and had higher noise. But when testing the sensor output with a voltmeter it was actually incredibly stable with just a 0.1 spread.

So now it was clear something was wrong with the ESP8266 module. Googling around I found a raised [issue on the Esp8266 Arduino github repository](https://github.com/esp8266/Arduino/issues/2070). And the explanation was pretty simple, because of the radio (transmitting & receiving) working then going to sleep, in between these states, there are spikes of voltage that affect the ADC module on the ESP8266 causing it to read values with a high degree of noise.

There is a solution. Or a couple of them.. I did try to disable the wifi, read ADC, enable the WiFi again but that did not work.. the WiFi would not reconnect.. so I gave up on that one.

The solution that did work for me was the disabling the radio sleep. There are two parts to that. First declaring the include:
{% highlight cpp %}
extern "C" {
#include "user_interface.h"
}
{% endhighlight %}
and next in the setup() method add the line:
{% highlight cpp %}
wifi_set_sleep_type(NONE_SLEEP_T);
{% endhighlight %}
That's all. Now the ADC should be pretty stable.
