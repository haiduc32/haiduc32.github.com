---
layout: post
title: IoC and circular references
date: 2011-08-29 20:44:05.000000000 +03:00
categories: []
tags:
- Inversion of Control
- IoC
status: publish
type: post
published: true
post_id: ioc-and-circular-reference
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
We rarely learn from our mistakes, or from the mistakes of our predecessors. This article is about what you shouldn't do, but if you still did it how to mess it right.

My story is about a project where the developers decided to use Inversion of Control (I'll use IoC from here on) in order to be able to simplify Unit Testing of their classes. Most of this classes where in the business layer. But as the time went by the classes would multiply and grow bigger and bigger, and some classes would require references to other classes, other classes to another other classes, and the last will end up trying to reference the first.. with no luck. IoC framework said "enough is enough" and threw a nasty exception.

Then, some developers scratched their heads, and decided to try and refactor. They went and extracted the methods that were generating the circular reference into separate classes, and for the moment everybody was happy.

But as the time went by even further, the references got tangled even more, and not even the bravest developers adventured to untangle them. Developers also realized that too many instances were being created because of the IoC that was injecting all references into the constructor, so each time a class was instantiated, all it's references were instantiated as well, along with all of their references, and so on, and so on.. And all they needed at a time was just a few of them..

"So what can we do?" they said.

But the answer was pretty simple, lazy loading. Protected properties will do the trick. Also helps with Unit Testing, as a mock/stub object can be set. Generic code, should work with most of IoC frameworks:

    protected ISomeComponent SomeComponent
    {
        get
        {
            if (_someComponent == null)
            {
                _someComponent = IoCContainer.Resolve<ISomeComponent>();
            }
            return _someComponent;
        }
        set { _someComponent = value; }
    }
    private ISomeComponent _someComponent;

The property is not public because some IoC frameworks will try and inject an instance to the property if they have a config for the interface.

In the constructor parameters only references that are always used should be kept, like the repository.

It's a bit weird to have classes that in the end reference each other. No sane compiler in the world would let you build such sources, but with IoC it's a very simple thing to do. A part of me is almost ready to advocate for circular references as something natural for service classes. You might find yourself in the situation when you have two classes that want to use methods from each other. Any sane person at this moment will say that the classes must be refactored, to extract the common methods into a separate class. But what if that is just another way to do it? What if..

Keeping this post short, use IoC responsibly (let's not forget about the huge config you have to do for all the classes that must be injected). Group  your service classes into a hierarchy so you know who can reference who, and no horizontal references.  If you do decide to berserk and mess up all the references, and you survive that adventure, please let me know.

Code responsibly.
