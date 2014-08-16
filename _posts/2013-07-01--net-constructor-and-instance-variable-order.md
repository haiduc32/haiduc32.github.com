---
layout: post
title: .Net constructor and instance variable order
date: 2013-07-01 20:54:25.000000000 +03:00
categories: []
tags: []
status: draft
type: post
published: false
meta:
  _edit_last: '1'
  _syntaxhighlighter_encoded: '1'
  _oembed_197c6d78c2396ee1392093b025a5724c: '{{unknown}}'
  _oembed_8c6b2bba349b1bc40d023c26a3d1c398: '{{unknown}}'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
<p>In the era of internet, less developers learn by reading the specs, but mostly by learning from examples. When learning by examples a lot of aspects are lost. Take a book on C#. Read it from first page till the last, and even if you're an experienced programmer, you'll find quite a lot of things you didn't know or forgot.</p>
<p>[csharp]<br />
--need an example with inheritance<br />
class A<br />
{<br />
  private int a = 10;</p>
<p>  public int AProperty { get { return a; } }</p>
<p>  public A()<br />
  {<br />
    a = 20;<br />
  }<br />
}<br />
[/csharp]</p>
<p>When you instantiate an object of class A, what will be the value of AProperty? If you thought 20, you are correct.</p>
<p>The simple rule of thumb would be: first the global variables are instantiated, in the order they appear in the class, from the derived class down to the base class, then the constructors are executed from the base class up to the derived class. Boring.</p>
<p>It's the statics where everything gets more interesting.. and confusing.<br />
http://msdn.microsoft.com/en-us/library/aa645758(v=vs.71).aspx<br />
http://msdn.microsoft.com/en-us/library/aa645612(v=vs.71).aspx</p>
