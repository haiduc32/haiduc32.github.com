---
layout: post
title: Building custom filters with ANTLR
author:
  login: admin
  email: haiduc32@gmail.com
  display_name: Radu
  
---
A week ago I got curious to how I coudl implement a custom filter for an application. And by custom filter I mean a textbox where the user could write an expression for filtering the date that would be showin in some grid.

So I started my journey on the wide Internet, and after reading countless similar questions on stackoverflow, I got to ANTLR. <what is antlr>

So what I was able to do, was to generate the code that would parse my input string, into a tree and then by visiting each node, to generate a MongoDB query. Later on I did the same exercise for LINQ.

OK, so let's dissect the basics to getting started with ANTLR.

### The Problem

All I wanted was just basic expression lie:
	
```
Username == "root" && (Level = "Error" || Level == "Warning")
```

Writing string a parser in C# or any language is not something I would enjoy doint. There is too much stuff that needs to be taken care of.

### The Solution

OK, so I already revealed the solution.. It's ANTLR. What it can do for you? Well.. not much.. besides generating code in C#, JAVA, C, (fill in your weapon of choice).

You'll have to define the language that will be parsed by the ANTLR. This will be the base for generating the source code that can be used for parsing strings and transforming them into trees). With a bit of reading online, and looking through other examples you should be fine with building basic languages.

### Where to start..

First thing first. Before using ANTLR we have to install it. Stop rolling your eyes! It's as simple as adding a nuget package. Search for ANTLR in the nuget repository, and select ANTLR 4. This will add ANTLR parser and runtime.

Or we can just write 
```
Install-Package Antlr4
```
in the Package Manager Console.

There is one more step that is recommended. Installing the ANTLR Language Support from Tools > Extensions and Updates. Because we want syntax highlighting, and most importantly to have the file types in Add New Item.

### Defining our first language

Now we can start defining the syntax for the filter. First, Add > New Item on the project. Search for ANTLR and select ANTLR 4 Combined Grammar. After the item is added to the project, we'll notice 3 files, we should do a Rebuild and then restart the solution. We'll notice that the .cs files are now under the g4 file. That's the workarround that works for me.

I won't go into how ANLTR works, and language syntax. I myself barely scratched the surface. Here is how I defined my language:

```
grammar FilterGrammar;@lexer::members{    protected const int EOF = Eof;    protected const int HIDDEN = Hidden;}prog: filter+ ;filter : expr           # Same       | filter '&&' filter # And       | filter '||' filter # Or       | '(' filter ')' # Parens       ;expr   : identif op=('=='|'!='|'>'|'<'|'<='|'>=')  va       | va op=('=='|'!='|'>'|'<'|'<='|'>=')  identif       ;va     : INT            # Int       | FLOAT          # Float       | STRING         # String       ;identif: IDENTIFIER (DOT IDENTIFIER)*     # Identifier       ;INT : [0-9]+;FLOAT: [-+]?[0-9]+('.'[0-9]+)?;STRING : '"' .*? '"' ; IDENTIFIER : [_a-zA-Z][_a-zA-Z0-9]*;AND : '&&';OR : '||';EQUALS : '==';NOT_EQUAL : '!=';GREATER : '>';LESS : '<';GREATER_OR_EQUAL : '>=';LESS_OR_EQUAL : '<=';DOT : '.';WS    :   (' ' | '\r' | '\n') -> channel(HIDDEN)    ;
```

If we start from the buttom, you'll notice that there are more-or-less-regex-expressions binded to a name. That's how the very basic parts of the language will be identified. For example and identifier can be _test, but can't be 0_test.

Going up, I've defined va (stands for value) as something that is identified by INT, FLOAT or STRING pattern.

Next, the exp (stands for expression) is the basic logic bloc. It defines what comparison operations the language allows and what is allowed on the left and right side. You can notice that you can have va on left and identif on right, or the other way arround, but not va on both sides, or identif on both sides. The op (operators) are just a few because I wanted to keep it stupid simple.

The last thing, that matters here, is the filter that is defined as either a basic expression, or construction of filter (that can be basic expression, or a complex construction of filter.. ok, you know.. inception style). The important part is the order of '&&'and '||'. I want to keep the classical priority of operators. That means that 
A || B && C will first evaluate B && C.

If we hit build, we should notice in the obj\Debug folder lots of .cs files that don't appear in our solution. 

### Building the Visitor

Ok, let's transform the parsed string into a MongoDB filter. Here's the finished version of the visitor:

