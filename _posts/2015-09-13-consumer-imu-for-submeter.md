---
layout: post
title: Consumer IMUs for sub-meter applications
date: 2015-06-25
categories: []
tags: []
status: draft
type: post
published: false
post_id: consumer_imu-for-submeter
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''  

---
I've been playing with a consumer grade IMU (Inertial Measurment Unit) for a couple of days now. The idea was to use an IMU chip to track the relative position of a robot. Unfortunately it looks like the technology isn't there yet.

I got an MPU9150 chip on a break-out board. The beauty of it is that it has 9Degrees fo freedom: it has accelerometer on X, Y and Z axes, gyro also on these 3 axis, and (wait for it) Magnetometer (aka Compass) on all 3 axis!

So in theory you could calculate from all this pletora of information your relativ position to a starting point. Well.. not so much. Two things make this task almost impossible: drift and noise.

I'm talking about a 4x4x1mm sensor, just like the one you probably have installed in your smart phone (yes, iPhones have the same consumer grade sensors). Airplains and submarines have gigantic giroscope sensors that give a much better quality of data. Even helicopters have some serious grade IMU units that give much more accurate data. The chips are consumer grade, and nobody really cares if it gives a few degrees of error in your phone.. unlike in airplanes/submarines/helicopters.

So no, you can't use a cheap 4x4x1mm sensor on a cruise missile. Tracking gestures, bumps, taps, etc. is ok, you don't need accurate data.

That was your executive summary, keep reading on if you want to dive into the technical details.

So going into technical details.. I have a MPU9150 (there is a MPU9250 - it has more granular Accerometer data, but don't expect to behave any better in terms of noise and drift). I wired it to a breadboard with an ATMega32u4 running on 3.3V, clocked at 8MHz with a Arduino Leonardo bootloader.

My goal was to use the sensor for detecting relative position (relative to the starting point) of a robot inside a ring of about 20-25cm diameter. That means I need a resolution of at least 0.5cm. And keep in mind that the accereometer sensor gives you the accerelation that you need to calculate the speed and distance of travel. With a resolution of about 16k increments per G (gravity) an acceleration of about 