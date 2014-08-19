---
layout: post
title: Entity Framework and Oracle Boolean
date: 2011-08-18 22:29:25.000000000 +03:00
categories:
- Entity Framework
tags:
- Entity Framework
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
#### Problems with Legacy Systems
Nobody likes working with legacy systems. You have so many constraints that all the fun goes away. The main concern is how not to break something that works.

So here I am working on a software application that depends on a legacy Oracle DB, with conventions for creating new DBs that don't really mix well with Entity Framework. One of the very first frustrations was the way boolean values were stored, with a varchar of 'Y' or 'N'. You don't expect Entity Framework to figure it out for you. In order to support Oracle DBs we used dotConnect which comes with it's one designer called Entity Developer, but it can map boolean values only to numeric fields of size 1.

When we had to make a query it would look like that:

    IEnumerable<Product> onSaleProducts =
        repository.Products.Where(x => x.OnSale == OracleBool.Yes);

Also, there is a need for conversion when you need to use the field in conditions to compare with other variables, when getting the values as parameter to a method, when sending the value to another method as parameter, etc. It's not the end of the world, but it's definitively a thing that would stress any self respecting developer.

#### In search of a solution
From the start of the project I've set myself a goal to figure out how to map the 'Y' and 'N' to boolean true and false in our entities. Because we are using POCO I thought all I needed was the support of attributes in the EF designer, so I could manipulate how the POCO objects where generated. Whell, it was eventually supported in a later version of Entity Developer, but it proved not near to enough.

I've spent a lot of hours trying to get a working solution, tried many approaches, and I finally got it. The final missing piece was inspired from the Davy Landman plog post <a title="Adding support for enum properties on your entities in Entity Framework" href="http://landman-code.blogspot.com/2010/08/adding-support-for-enum-properties-on.html" target="_blank">Adding support for enum properties on your entities in Entity Framework</a>. It took some magic with operators and expression trees to get it all rolling.

#### The solution
The solution is a set of classes that you must copy to your project, creating a complex type from EF designer (default one in Visual Studio is just fine) with a partial class that is found in the provided zip, and finally wrapping the ObjectSet which can be done in multiple ways.

First of all download all the required classes: <a href="http://www.blog.cyberkinetx.com/wp-content/uploads/2011/08/EFExtensions.zip">EFExtensions</a>. The four classes: ObjectQueryWrapperProvider.cs, WrappedFieldsObjectQuery.cs, WrappedFieldsObjectSet.cs, WrappedFieldsTranslator.cs; should be copied to the project where the Entity Framework Context is defined. The DbBool.Partial.cs we'll need later.

Go to the EF designer, right click on the property that is string but you want to be as boolean, click 'Refactor into New Complex Type', rename it back to the original name. From the Model Browser rename the new type as DbBool. The single property, inside, rename to Value. Consider this all as conventions.

Now that you have the new DbBool class generated in your solution explorer, copy the DbBool.Partial.cs where the DbBool.cs was generated, and correct it's namespace.

You're almost there. All you have to do is wrap the ObjectSet. There are more ways to do it. If you have some kind of repository, or DAL that wraps the EF context you can do it there with something like:


    IEnumerable<Product> GetOnSaleProducts()
    {
        using (DbContext context = new DbContext())
        {
            return (new WrappedFieldsObjectSet<User>(context.Products))
                .Where(x => x.OnSale == OracleBool.Yes).ToList();
        }
    }

If you are using POCO, and have a template for that, you can tweak the template to automatically wrap your ObjectSet for each type. Something like:

    public WrappedFieldsObjectSet<Product> Products
    {
        get { return _products?? (_products = new WrappedFieldsObjectSet<Product>(CreateObjectSet<Product>("Products"))); }
    }
    private WrappedFieldsObjectSet<Product> _products;

That way the wrapping is done transparently and you can enjoy writing queries like:

    IEnumerable<Product> onSaleProducts =
        repository.Products.Where(x => x.OnSale);

One 'little' inconvenience is when you have to transform a property from string to DbBool complex type. There seems to be no direct way to do it in the designer. The steps you have to take are: in EF designer rename the property into something else, so you can add another property with the desired name. Add a complex type property with the old name of the property you just renamed. Check that the type of the complex property is DbBool. Right click on the entity in designer, and select 'Table Mapping'. Remap the the field to the new property. Delete the old property. A bit cumbersome, but the benefits of using the property as boolean will pay off.

#### Extra bonus
Here are the steps to tweaking the default POCO template to automatically wrap the ObjectSets. In the ***.Context.tt find:

  using System;
  using System.Data.Objects;
  using System.Data.EntityClient;

And add **using EFExtensions;**. Next, replace:

    <#=Accessibility.ForReadOnlyProperty(entitySet)#> ObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.Escape(entitySet)#>
    {
        get { return <#=code.FieldName(entitySet) #>  ?? (<#=code.FieldName(entitySet)#> = CreateObjectSet<<#=code.Escape(entitySet.ElementType)#>>("<#=entitySet.Name#>"")); }
    }
    private ObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.FieldName(entitySet)#>;

With:

    <#=Accessibility.ForReadOnlyProperty(entitySet)#> WrappedFieldsObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.Escape(entitySet)#>
    {
        get { return <#=code.FieldName(entitySet) #>  ?? (<#=code.FieldName(entitySet)#> = new WrappedFieldsObjectSet<<#=code.Escape(entitySet.ElementType)#>>(CreateObjectSet<<#=code.Escape(entitySet.ElementType)#>>("<#=entitySet.Name#>""))); }
    }
    private WrappedFieldsObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.FieldName(entitySet)#>;

