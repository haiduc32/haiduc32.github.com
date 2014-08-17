---
layout: post
title: List parameters check
date: 2012-07-09 09:21:07.000000000 +03:00
categories: []
tags: []
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
This time a short post about sending list parameters. I've been reading yesterday an interesting <a href="http://thecodelesscode.com/case/6">Kōan</a> about sending list parameters and validating list parameters, and by a strange coincidence, later on I found a very nasty bug in my code related to lists.

I've seen uncountable times people checking the input parameter, a list one, for null or empty before considering that there is nothing to process. Just as many times I've seen people sending null for the list parameter if there was nothing to send.

Let's dissect the call to a method with a list parameter.

    public void CheckOut(List<Product> products)
    {
        //..don't care for the implementation now
    }

If the customer has 0 products in his cart, what will be passed in the products parameter? null? Your cart is empty, so how about sending an empty list of products to CheckOut. (Of course this might not be the best way, you should probably have a verification before, but also the CheckOut should verify that it receives any products.)

Of course null can be used in some cases as a different state of the parameter, not the list. For instance, the optional parameters might be setup to have default value null, which will mean that it has not been passed by the calling code. The bottom line is, there are empty lists, that you should send if you have no elements, and there is the null, that means.. null.
