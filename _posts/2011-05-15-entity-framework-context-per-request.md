---
layout: post
title: Entity Framework context per request
date: 2011-05-15 12:09:16.000000000 +03:00
categories:
- CodeProject
tags:
- EF
- Entity Framework
- Unit Of Work
- unitofwork
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
Are you still using the

  using (DBContext context = new DBContext())
  {
    ..
  }

way of accessing the database? I mean that's cool, at least you are sure you don't have connection pooling penalties. But where do you write this code? Do you have a Data Access Layer? How about accessing the Navigation Properties outside the using block? How about assuring a developer does not forget about the context restrictions and tries to access a related table outside the context?

I've seen developers creating the context inline without a using block, and then not bothering about disposing it, leaving this "monkey business" to the garbage collector. Because it was a web service project with a lot of access I volunteered to fix it, and encapsulate all contexts in using blocks. I didn't bother to test it.. I mean what could go wrong, right? It was the DAL. Because of a combination of unfortunate events, the code found it's way to live and crashed.. Somebody was using a Navigation Property in the Business Layer. The only reason why it did not crash before was the garbage collector, it was not disposing the context fast enough, so you could still write some code in the business before the context was disposed. A race against time actually..

On the next project, my first idea was to make all Navigation Properties in the entities as internal only to the DAL. But then the architect suggesting we use linq on the entities from the BL. That means the Entity Framework context must continue its lifetime in the Business Layer. The solution? Unit Of Work.

First of all we created the Data Access Layer. Entity Framework as a concept is a DAL by itself, but we needed to separate it from our code for the sake of UT simplicity and because it simply is a good practice. It's a lot simple to mock an interface than the EF. Inside the DAL project we created the Repository class that did all the DB access job. Actually it has only CRUD operations. For example:

    public IQueryable Customers { get { ... } }
    
    public void Add(Customer customer)
    {
      ..
    }
    
    public void Delete(Object entity)
    {
      ..
    }

You may argue this are not CRUD because there is not Update operation. But because the Customer is exposed by the Customers property it can be updated by anybody outside the repository, and so it does expose the Update operation.

I skipped the implementation details as you are not ready to see it. All at it's time. Let's see what this CRUD operations give us. We have a repository that doesn't have for ex. GetCustomerOwingMoney(), or GetNewOrders(). From a OOP point of view that would be operations on the Customer collection and Order collections. It does make sens not to write them in our BL. Very well then, let's write them on the IQueryable<Customer> collection:

    public IQueryable<Customer> OwingMoney(this IQueryable<Customer> customers)
    {
      return customers.Where(x => x.Balance < 0);
    }

Hey, that's an extension method! We followed the OOP way and got ourselves a collection of customers with a OwingMoney() method on it. Ain't that awesome? As part of our project we created extension methods for all entities that needed operations on the collections (before putting just any method as an extension think first if it's a BL related or it'a an operation related to that particular type). As a convention the classes with extension methods are called CustomerExtensions, OrderExtensions, etc. Pushing that forward, we also have partial classes for the entities with properties and methods, like OwsMoney (taking the previous example), or Suspend() to suspend a customer if he refuses to pay. So the extensions can be used from the BL in a kind of fluent way.

A question that might arise at this point is - if we have all this logic in the extension method and in the partial classes, what do we actually put in the BL? And indeed there is no thin border where the extension methods end and the BL starts. So far our rule is to put all the reusable code where possible to the extension methods and partial classes, the rest would be the BL.  For example, let's say we need a method to suspend all customers that owe money to the shop, and have more than 2 open orders (i guess it has no logic but just for the sample sake), that can be done as an extension on the IQueryable<Customer>, but it will not be reused anywhere as it's an action that will be triggered by some scheduled process. So it makes a lot of sense to write it in the BL:

    public void SuspendBadCustomers()
    {
      repository.Customers.OwingMoney()
        .Where(x => x .Orders.OpenOrders.Count() > 2).ToList()
        .ForAll(x => x.Suspend());
    }

Does that make sense? Not with a classic repository. As far we didn't save the changes. We can just leave it like that. It will be saved.. eventually. And how in the world we dispose the context?? Oh well, we have the UnitOfWork for that.

Before I start discussing the UnitOfWork implementation I will assume you are familiar with Dependency Injection and Inversion of Control as explaining them is out of the scope of this post.

For the current post I will do a very simple UnitOfWork just to satisfy the problem of having a context persisted along the lifetime of the HTTP Request. More complext implementation would mean supporting multiple contexts, supporting different object persistence on the UnitOfWork.

    public class UnitOfWork : IUnitOfwork, IDisposable
    {
      public ObjectContext Context { get; set; }
      public DbTransaction Transaction { get; set; }
    
      public void Commit()
      {
        if (Context != null)
        {
          ObjectContext.SaveChanges();
          Transaction.Commit();
        }
      }
    
      public void Dispose()
      {
        if (Context != null)
        {
          Transaction.Dispose();
          Transaction = null;
          Context.Dispose();
          Context = null;
        }
      }
    }

Here we have 2 properties for Context and another for Transaction. Because of the per request behavior, we can't use the TransactionScope any more, so we'll go with a bit old fashion way of working with transactions.

Next step would be to configure the IoC container to treat IUnitOfWork with a lifetime that would give the same instance for a HTTP Request. Meaning, whenever I'll call my IoC like

    IUnitOfWork unit = IoCContainer.Resolve<IUnitOfWork>();

I will be getting the same instance of the UnitOfWork in a single HTTP Request (to not be confused with HTTP Session).

Next step is to configure the Global.asax to handle the UnitOfWork, committing it when the request ends, and just disposing it when an exception is thrown so the transaction will be rolled back. What you need to add to the Global.asax:

    public void Application_EndRequest(Object sender, EventArgs e)
    {
      IUnitOfWork unit =  IoCContainer.Resolve<IUnitOfWork>();
      unit.Commit();
      unit.Dispose();
    }
    
    public void Application_Error(Object sender, EventArgs e)
    {
      IUnitOfWork unit =  IoCContainer.Resolve<IUnitOfWork>();
      unit.Dispose();
      //don't forget to treat the error here
    }

No actions are required on BeginRequest event. But so far the Entity Framework context isn't initialized anywhere. It would make sense to initialize the context only when required. Some request might not hit the DB so why the extra penalty? Because I don't want my BL to know much about EF I decided to do the initialization in Repository. I created a GetContext() method that returns the context whenever it is required. And because dependency injection is used the UnitOfWork can be set up as a parameter in the constructor and it will be injected when the Repository is instantiated (preferably by IoC as well):

    public class Repository : IRepository
    {
      private IUnitOfWork unitOfWork;
    
      public Repository(IUnitOfWork unitOfWorkk)
      {
        this.unitOfWork = unitOfWork;
      }
    
      //CRUD operations code would be here
      //..</p>
    
      private OurDbContext GetContext()
      {
        if (unitOfWork.Context == null)
        {
          unitOfWork.Context = new OurDbContext();
          unitOfWork.Transaction = unitOfWork.Context.BeginTransaction();
        }
    
        return (OurDbContext)unitOfWork.Context;
      }
    }

We are almost there. Just have to update our CRUD operations example, with the GetContext():

    public IQueryable<Customer> Customers 
    {
      get { return GetContext().Customers; }
    }
    
    public void Add(Customer customer)
    {
      GetContext().Customers.Add(customer);
    }
    
    public void Delete(Object entity)
    {
      GetConetxt().DeleteObject(entity);
    }

We are there. Let's summarize what we got. We have a UnitOfWork that is a-kind-of-singleton, that is retrieved using IoC, and will have the same instance as long it's in the context of the same HTTP Request. In the repository whenever the first db operations is called a context and a transaction is created and saved on the UnitOfWork. The context will be reused in the repository as long as it's doing operations for the same HTTP Request. Whenever the HTTP Request ends (a HTTP Reply is issued to the client), in case of no exceptions the transaction will be committed and all changes will be saved to the database, in case of exceptions the transaction will be reverted and a nice message must be issued to the end user, and a error log should be created. On the next request another UnitOfWork is created and another context.

For the Business Layer, we have safe access to the Navigation Properties, extension methods can be used for any entities. Performance increases because BL does not access repository methods for different actions creating new instances of the ObjectContext.

I've been asked if keeping a context for so long isn't a performance issue by itself. The answer would be "depends". If you are building a web site like Facebook you'll probably search for other options (and most probably give up on EF). The pool size for the context has a default size of 100. That means you can have 100 requests that are processed in parallel, the 101 will wait for a context to be free. When you get to more then 100 parallel requests you'll probably have other bottlenecks to worry about, and will already be thinking about load balancing.

If I may return to the problem of SaveChanges(). In the presented examples it is never called from Repository or BL as the examples are fairly simple. In more complicated scenarios it will be necessary so in our implementation we have a Save() method implemented in the repository that simply calls the SaveChanges() on the context. A scenario when you need it would be when you add to repository new entities, and then do a Where() and expect to find them. Well.. if you want' save them before the Where() operation, you won't.. That's how EF works. Same with the changes. So if you need to add/update something and use that in the next query, do a save first. That has been one of my most common mistakes...

I did not treat the problem of lazy loading in this article as it's outside the scope but when you start working with EF and use a lot of Navigation Properties keep this problem in mind.

Got questions?
