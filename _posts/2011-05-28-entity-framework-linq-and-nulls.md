---
layout: post
title: Entity Framework, LINQ and NULLs
date: 2011-05-28 22:38:24.000000000 +03:00
categories: []
tags:
- EF
- Entity Framework
- LINQ
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
It now seems like I've been using LINQ forever, and I wouldn't give it up for anything in the world. I've grown so used to it that I miss it every time I write something in C or Java.

But I had a moment of WTF the other day when I implemented a most simple business requirement to filter the input by a field and submitted the application for testing, without bothering to check it first. (I must praise our testing team here, as we do a lot of very close collaborations. Testing features right after implementing them, fixing issues right after discovering them. Works great!)

After taking one more look at the code, I had the eureka expression, the one that I get every time that I discover something new to me but that makes absolute sense and I wander why haven't I found it earlier.

But let's go back to LINQ. Let's take a simple LINQ example:

    class Customer
    {
      public int Id { get; set; }
      public string Name { get; set; }
    }
    
    ..
    //somewhere in some method:
    List customers = new List
    {
      new Customer { Id = 10, Name = null },
      new Customer { Id = 11, Name = "John" },
      new Customer { Id = 12, Name = null }
    };
     
    foreach (Customer customer in customers.Where(x => x.Name != "John"))
    {
      Console.WriteLine(customer.Id);
    }

How do you think, what will be outputted to the console? Yes, you are right, 10 and 12. Makes perfect sense, doesn't it?

Now let's consider the case when we have a table "Customer", with exact same structure and we created a model with that table, so we have the "Customer" entity. I want to apply the same condition, to get all customers that don't have the name John. I will just reuse the old code for now:


    using (OurDbContext context = new OurDbContext())
    {
      foreach (Customer customer in context.Customers
        .Where(x => x.Name != "John"))
      {
        Console.WriteLine(customer.Id);
      }
    }

It should output 10 and 12. At least that's what I initially thought. If you expect the same, don't worry, you're not the only one. The actual output is nothing. No id's will be outputted. If by now you ask why you missed the fact that LINQ to Entities actually generates SQL code that is executed against the database. So now you must think in terms of SQL. What will an SQL query output if you try to **SELECT * FROM Customers WHERE Name != "John"**supposing that we have the same data as we initialized in our list earlier? Nothing. First and third records have the Name field Null. When SQL compares a null to anything else it returns Unknown, that is **false**. You can compare it however you like, with == or != it will always resolve to **false**.

As for the correct version:

    using (OurDbContext context = new OurDbContext())
    {
      foreach (Customer customer in context.Customers
        .Where(x => x.Name != "John" || x.Name == Null))
      {
        Console.WriteLine(customer.Id);
      }
    }

Code responsibly.
