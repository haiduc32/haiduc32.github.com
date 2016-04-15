---
layout: post
title: Trolling developers with Visual Studio
date: 2015-04-23
categories: []
tags: []
status: publish
type: post
published: true
post_id: trolling-developers-with-vs
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  first_name: ''
  last_name: ''  
---
You may or may not be aware that Visual Studio will try to compile your projects concurrently, to a certain degree. It's an old feature, and you can actually set the number of parallel project builds [How to: Set the Number of Concurrent Builds for Multiprocessor Builds](https://msdn.microsoft.com/en-us/library/y0xettzf%28v=vs.90%29.aspx).

But how this relates to trolling you ask? Well.. in the most dirrect way, though it's not that obvious.

So let me tell you a story. Once upon a time there was big project, with lots and lots of VS projects (about 80), and grouped them into a few solutions (about 10). Now, because the projects were reused across different solutions, the reference from one project to an assembly were defined at some output folder where all projects would output the dlls. Keeping referneces to projects inside the solution isn't possible if you have one solution where a referenced project isn't present.

Having the dlls outputed to a central location and referencing the dlls instead of projects works fine if you have the build order of the projects set correctly.. and you have only one build thread. But because VS will try to build your projects concurrently, you might end up in a situation when a referneced dlls is not yet built because it just started building. The build order does not ensure that a project will wait till another has been built, it just specifies in what order to start building them.

The worst thing about this is the errors. The compilation errors will not be the same from one build to another. You can get one missing assembly error on first build, and another on the second, and on the third again the first one, or the third one.. It's the ultimate trolling when you get different compilation errors when repeating the build.

Sure, setting the concurrent builds to 1 will solve this. But this is wrong in so many ways.. Visual studio has a Project Dependencies dialog (right click on the solution -> Project Dependencies..) where for each project you can set the project it depends on, even if it does not reference them dirrectly. That would solve the problem and you can continue to use concurrent builds to speed up the compilation.

Happy trolling!

