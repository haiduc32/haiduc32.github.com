---
layout: post
title: C# brain teasers
date: 2011-09-04 17:58:07.000000000 +03:00
categories: []
tags:
- brain teaser
- c#
status: publish
type: post
published: true
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
Recently I've stumbled upon a few brain teasers on C# and it was fun trying to figure out the answers to the problems. So here are a few simple brain teasers from me.

### Teaser 1
What will be displayed in the console?

    void foo(int a, int b, int c)
    {
        Console.WriteLine(a);
        Console.WriteLine(b);
        Console.WriteLine(c);
    }
    
    .....
    
    int i = 0;
    
    foo(i++, i++, i++);

### Teaser 2
Will that compile?

    enum E { A, B, C, }

### Teaser 3
How about that:

    void foo(string s) {...}
    
    void foo(StringBuilder sb) {...}
    
    ....
    foo(null);

No answers provided. You want to know the answers, you have to try it yourself, no fun otherwise.

More teasers <a href="http://www.yoda.arachsys.com/csharp/teasers.html" target="_blank">here</a> and <a href="http://www.ahuwanya.net/blog/post/C-Brainteasers-Part-I.aspx" target="_blank">here</a>. Got a brain teaser? Drop a comment.
