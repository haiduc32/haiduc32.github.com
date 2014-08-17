---
layout: post
title: Understanding strings a little bit better
date: 2013-06-30 09:31:24.000000000 +03:00
categories: []
tags: []
status: publish
type: post
published: true
post_id: 10
meta:
  _edit_last: '1'
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''
---
This article was born because of 4 lines of code that baffled most of the developers I've shown it to.

	string a = "ab";
	string b = "ab";
	bool referenceEquals = object.ReferenceEquals(a, b);
	Console.WriteLine(referenceEquals);

Take a moment to think what you'd expect to get printed on screen, and why.

Now let's check another example:

	string a = "ab";
	string b = "a";
	b += "b";
	bool referenceEquals = object.ReferenceEquals(a, b);
	Console.WriteLine(referenceEquals);

Same question here. What will be printed on screen, and why.

By now you might be opening the Visual Studio, copy-pasting the samples and running them, trying to figure out what is wrong with the world. If not, I'll just make it easier for you and tell you that the answer to the first sample is True, and for the second False. Now you most probably have 2 questions that won't let you sleep till you know the answer: first, why in the first sample the output is True? second, why in the second sample the output is different from the first.

To make it even a bit worse, let's revise the samples (might notice similarities with the MSDN samples here):

    string a = "ab";
    string b = "ab";
    Console.WriteLine(a == b);
    bool referenceEquals = object.ReferenceEquals(a, b);
    Console.WriteLine(referenceEquals);

    string a = "ab";
    string b = "a";
    b += "b";
    Console.WriteLine(a == b);
    bool referenceEquals = object.ReferenceEquals(a, b);
    Console.WriteLine(referenceEquals);

I've added a line to compare the value of the strings. <a href="http://msdn.microsoft.com/en-us/library/vstudio/362314fe.aspx" target="_blank">The equality operator compares strings by value, not by reference.</a> The outputs will be:

    True
    True
    
    True
    False

Now you got your proof that the strings are identical. Also the references are identical in the first sample, but not in the second. From <a href="http://msdn.microsoft.com/en-us/library/system.string.intern.aspx" target="_blank">MSDN</a>:

> The common language runtime conserves string storage by maintaining a table, called the intern pool, that contains a single reference to each unique literal string declared or created programmatically in your program. Consequently, an instance of a literal string with a particular value only exists once in the system.

In other words, all the literals that you have at the moment of compilation, are added in a table (a pool), with unique values. If you have 2 variables with same string literal, they will both have the same reference, because it's the same string from the string pool. So, in the first sampla, both variables *a* and *b* reference the same string from the string pool. On the other hand if you create a string at runtime, it just creates a **new** immutable string object, that's why in the second sample *a* has a string reference from the pool, and *b* is a new immutable string object, created at runtime.

Also there is a method to add your strings to the string pool (or get the existing reference), <a href="http://msdn.microsoft.com/en-us/library/system.string.intern.aspx" target="_blank">String.Intern Method</a>:

    string a = "ab";
    string b = "a";
    b = String.Intern(b + "b");
    Console.WriteLine(a == b);
    bool referenceEquals = object.ReferenceEquals(a, b);
    Console.WriteLine(referenceEquals);

In this case you'll get both outputs True. The MSDN page on that method also explains a bit more about the strings. During researching for this post I've found another interesting <a href="http://broadcast.oreilly.com/2010/08/understanding-c-stringintern-m.html" target="_blank">article on O'Reilly </a> that explains aspects of String.Intern.

Happy coding!
