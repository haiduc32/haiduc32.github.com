---
layout: post
title: Entity Framework and enums aka EFExtensions
date: 2011-08-21 22:33:53.000000000 +03:00
categories:
- Entity Framework
- Projects
tags:
- EF
- EFExensions
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
How would you like to write that:

    User foundUser = context.Users.FirstOrDefault(x =>
        x.Username == "OneUsername" &&
        x.CountryCode == CountryCodeEnum.UK &&
        x.AccessLevel == AccessLevelEnum.Admin &&
        x.Active);

When CountryCode is of type string, AccessLevel is an int and Active is string that can be "Y" or "N".

Here 2 important demonstrations are done. First it's the support of enums, that can be of numeric value or string value. Second, support for non orthodox booleans of "Y" and "N" that can be found in Oracle databases.

### Behind the scene
If you aren't really interested in how it became possible to do that you can skip to the Prerequisites.

In my previous post I described how to add support for custom booleans, like "Y" and "N", but I didn't really explain how it works behind the scene.

For each property that we want to have a custom mapping we create a complex type, the property becoming a complex property. The single property of the new complex type must be renamed to Value, as a convention so we can create templates for it and find it easily with reflection (call it hard coding if you will).

The POCO template is adjusted to insert custom code in the generated class for the complex type. The code deals with implicit casting to enums, operators that do comparison between the complex type and enums, overridden methods from object class, helper method, etc. The template checks for attributes set on the complex type from the Entity Developer.

For custom boolean mapping, the POCO template is adjusted to check for DbBool name for complex types, so no need for extra attributes here.

And the most important, the ObjectSet<> is wrapped with an ObjectSetWrapper, that will replace in the expression trees, the members properties that use directly the complex type with the actual Value property like: x.CountryCode => x.CountryCode.Value. For boolean it will be: x.Active => x.Active.Value == "Y".

There is also an EnumMapper that can handle the transformation between an enum and the value that will be replaced in the expression tree. In order to support string values I've created a new attribute that is used on enums:

    public enum CountryCodeEnum
    {
        [EnumValue(Value = "US")]
        USA,
        [EnumValue(Value = "UK")]
        UK
    }

The EnumMapper will check for the attribute when mapping the enums to values, and will set string value when the attribute is found, or numeric value if there is no attribute.

I hope that covers all the important aspects.

### Prerequisites
Unfortunately I couldn't find any way to do it elegantly with the default EF designer, so I went with Entity Developer, from <a title="Devart" href="http://devart.com" target="_blank">devart.com</a>. It also comes  bundled with their dotConnect product, an ADO.NET provider for a variety of databases. I used it for it's support of attributes in the model. There is a free version for MSSQL, but it has a limitation on the number of entities you can import. I suggest you start creating your model with Entity Developer from the start, as I found some compatibility issues when opening a model created with default Entity Framework designer.

Second prerequisite, you must use POCO objects generated with Visual Studio default T4 templates. Otherwise (for instance if you're using the templates found in Entity Developer).. it's on you to tweak the provided include template included with EFExtensions.

Third, download the latest version of EFExtensions library from github <a href="https://github.com/haiduc32/EFExtensions" target="_blank">here</a>.

### Getting dirty
We got all we need, so let's get to work. First of all import the downloaded EFExtensions library into the project where you model is defined. Or you can get the project sources, if you intend on tweaking it, and referencing it instead.

Open your model in Entity Developer. Go to Model -> Settings. On the left side there is a tree navigation, select Attributes. Now click on Add.. and find the EFExtensions assembly (if you chose to use the project with sources search for it in your bin\debug dirrectory). Once you found it, hit OK. Uncheck the EFExtensions.EnumValueAttribute as you don't need it. You should see something like this:

![Attributes list]({{ site.url }}/assets/attr1.png)

Next go to a property that you want to support enums. Right click, select Migrate.., the default selection in the new window will be New complex type, that's just what we need. Enter a name, I'd suggest setting a convention to name all complex types that are to support enums to "Db<Name>Enum".

![Adding a complex type]({{ site.url }}/assets/complex1.png)

Once you hit OK the property will be renamed to the name of the complex type, you don't need that so rename it back. In the Model Explorer under Complex Types find the type you just created and change the name it's single property to Value, consider that a convention. For me it looks like:

![Value property name]({{ site.url }}/assets/complex2.png)

Select the complex type and under Properties panel find the Attributes property. Select it and click the small button on the right side of (Collection), in the new window select the DbEnumAttribute and click on the arrow button that points to the right, so it will be added in the list of Selected Attributes. Now in the Properties list, set the full name(including the full namespace) for the Target Enum Type. This is the enum that you want to support for your complex property. In my example it is Experimental.CountryCodeEnum. In the image you can see arrows where you have to action.

![Setting attributes]({{ site.url }}/assets/complex3.png)

Once you click OK you can move to the next property that you want to support enums or custom boolean.
To map a property to custom boolean that is mapped to Y and N all you have to do is create a complex type with the name of DbBool, with a single property named also Value. No need to add attributes here.

If you need to map more fields in your entities to the same complex type select Migrate... and then select Existing complex type.

### Getting even dirtier
Changing the model to support enums is all very nice but you can finish that later. Now we have to get real dirty with the T4 template to generate correctly the code for our complex types and also to automatically wrap the ObjectSets. As mentioned in the Prerequisites section, support is provided for default POCO template that you can find in Visual Studio. For support with other templates you might need to get into the EFExtensions.ttinclude and adapt it.

In the folder with EFExtensions find EFExtensions.ttinclude file and copy it to your directory with the POCO templates. You don't have to include it in the poject, just let it be in the same folder. If that doesn't work for you, try moving it to the base folder of the project.

With default POCO templates you have 2 .tt files, one ending with .Context.tt. Open that one and find:

    using System;
    using System.Data.Objects;
    using System.Data.EntityClient;

Add **using EFExtensions;**. Next, replace:

    <#=Accessibility.ForReadOnlyProperty(entitySet)#> ObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.Escape(entitySet)#>
    {
        get { return <#=code.FieldName(entitySet) #>  ?? (<#=code.FieldName(entitySet)#> = CreateObjectSet<<#=code.Escape(entitySet.ElementType)#>>("<#=entitySet.Name#>")); }
    }
    private ObjectSet<<#=code.Escape(entitySet.ElementType)#>> <#=code.FieldName(entitySet)#>;

With:

    <#=Accessibility.ForReadOnlyProperty(entitySet)#> ObjectSetWrapper<<#=code.Escape(entitySet.ElementType)#>> <#=code.Escape(entitySet)#>
    {
        get { return <#=code.FieldName(entitySet) #>  ?? (<#=code.FieldName(entitySet)#> = new ObjectSetWrapper<<#=code.Escape(entitySet.ElementType)#>>(CreateObjectSet<<#=code.Escape(entitySet.ElementType)#>>("<#=entitySet.Name#>"))); }
    }
    private ObjectSetWrapper<<#=code.Escape(entitySet.ElementType)#>> <#=code.FieldName(entitySet)#>;

Now open the other one. At the very top find:

    <#@ template language="C#" debug="false" hostspecific="true"#>
    <#@ include file="EF.Utility.CS.ttinclude"#><#@

Add the EFExtensions.ttinclude:

    <#@ template language="C#" debug="false" hostspecific="true"#>
    <#@ include file="EF.Utility.CS.ttinclude"#>
    <#@ include file="EFExtensions.ttinclude"#><#@

Find the line that writes the class name for complex types:

    <#=Accessibility.ForType(complex)#> partial class <#=code.Escape(complex)#>

Add the code to insert interface if the complex type has the attribute DbEnumAttribute:

    <#=Accessibility.ForType(complex)#> partial class <#=code.Escape(complex)#> <#=CheckDbEnum(complex) ? ": " + GetDbEnumInterface(complex) : ""#>

Now scroll down and find the line that has region.End(); and after that EndNamespace(namespaceName); Something like:

        region.End();
    #>
    }
    <#
        EndNamespace(namespaceName);
    }

Insert WriteDbBoolSupport(complex); and WriteEnumSupport(complex); right after region.End();

        region.End();</p>
        WriteDbBoolSupport(complex);
        WriteEnumSupport(complex);
    #>
    }
    <#
        EndNamespace(namespaceName);
    }

This is where the extra code will be inserted. You can save and close the file now.
### Almost there
So the complex types are created, the custom code is being generated.. what else? Ah, yes, when you want to use a string value for an enum, like I did for CountryCodeEnum, UK corresponds to "UK", USA to "US", so it's not a ToString() mapping. In order to have this string values add on each enum constant the EnumValueAttribute(Value = "whatever value you want"). Let's review my previous example:


    public enum CountryCodeEnum
    {
        [EnumValue(Value = "US")]
        USA,
        [EnumValue(Value = "UK")]
        UK
    }

If the attribute is not set the value will be same as doing a (int)CountryCodeEnum.USA.

Don't forget to add a reference to EFExtensions if you have your enums in another project.

### Let's talk about usage
Now that my User entity has complex properties that can be assigned and compared to enums, or booleans what can I do what is not possible out of the box with Entity Framework?

Whell how about that:

    User newUser = new User
    {
        Active = true,
        CountryCode = CountryCodeEnum.UK,
        Username = "OneUsername",
        AccessLevel = AccessLevelEnum.User
    }

You've seen how CountryCodeEnum looks like, now the AccessLevelEnum:

    public enum AccessLevelEnum
    {
        Deny = 0,
        User = 1,
        Admin = 99
    }

Let's get all inactive users:

    IEnumerable inactiveUsers = context.Users.Where(x => !x.Active);

Or.. All users from UK:

    IEnumerable inactiveUsers = context.Users
        .Where(x => x.CountryCode == CountryCodeEnum.UK);

And also I can compare it with a string value:

    IEnumerable inactiveUsers = context.Users
        .Where(x => x.CountryCode.Value == "UK");

### Afterword
Congratulations, now you know how to use enums with LINQ to Entities.

Also I'd like to mention the post by Davy Landman that helped me find the missing piece for my solution: <a title="Adding support for enum properties on your entities in Entity Framework" href="http://landman-code.blogspot.com/2010/08/adding-support-for-enum-properties-on.html" target="_blank">Adding support for enum properties on your entities in Entity Framework</a>. But unfortunately the presented solution supports only enums of numeric type.

If you find any bugs, or want to improve the solution you can do that on github, contributions are appreciated.

All that being said, have fun!
