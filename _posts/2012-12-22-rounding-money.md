---
layout: post
title: Rounding money
date: 2012-12-22 23:32:42.000000000 +02:00
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
When working with financial projects, at some point or other you end up splitting some amounts across products, subscriptions, insurers, etc., at which moment you might have to solve the rounding issues. Let's consider a (pretty real) case when you have to split a payment, across multiple subscriptions. Say the customer is subscribed to multiple services, and can pay partially. In this case, some companies will split the money proportionally across the due subscriptions. For simplicity of calculation let's take 3 subscriptions of 1$ each:

    Internet - 1$
    TV - 1$
    Phone - 1$

If the customer chooses to pay 2$ (to delay the suspension of his account), the application will have to split the 2$ across all 3 subscriptions. Now a junior will rush to split  the amounts, and use Round() to two decimal points. That might sound fine if the company doesn't care about loosing 2c (yes, 2 not 1):

    2/3 = 0.66666666....
    After rounding each will get:
    Internet = 0.67
    TV = 0.67
    Phone = 0.67

Now if you add up 0.67 3 times and get 2.02$, but hey, the customer only payed 2.00$. Let's call it acceptable loses. Consider next scenario, when a customer pays only 1$:

    1/3 = 0.33333333....
    After rounding each will get:
    Internet = 0.33
    TV = 0.33
    Phone = 0.33

If you add it up 0.33 3 times you get 0.99$. I bet the customer won't like to see on his next bill that he still has to pay 2.01$ instead of 2.00$. That reminds me of <a title="Office Space" href="http://www.imdb.com/title/tt0151804/">Office Space</a>.

Second option is to split the amount proportionally across the subscriptions and then to round down on all 3 payments. After that subtract from the whole payment, the split payments, and get the amount of error. This error to apply on the last/first subscription. That sounds fine, you don't get rounding errors. Or so you think. Again, in some cases you might end up overpaying the last/first subscription, and underpaying the other 2. Depending how the system is built, even after the customer pays the rest 42$, it might consider that there is still debt on some subscriptions. And the over payed subscription might have the extra cents forever. Let's make each subscription 2$, and the customer will pay 3 installments of 2$ each:

**1st installment**

    Internet = 2 / 6 * 2 = 0.66
    TV = 2 / 6 * 2 = 0.66
    Phone = 2 / 6 * 2 = 0.66
    Error = 2 - (0.66 * 3) = 0.02 - add it to Phone subscription
    Phone = 0.66 + 0.02 = 0.68

**2nd installment**

    Internet = 0.66 + 0.66 = 1.32
    TV = 0.66 + 0.66 = 1.32
    Phone = 0.68 + 0.66 + 0.02 (which is the error again) = 1.36

**3rd installment**

    Internet = 1.32 + 0.66 = 1.98
    TV = 1.32 + 0.66 = 1.98
    Phone = 1.36 + 0.66 + 0.02 (which is the error again) = 2.04

The total amount is correct, but the distribution is not. In some cases it might not be important. But most of the time it'll be a problem.

Third option (and the most correct one). First of all, take the 2$ and split it by the remaining amount to be payed on each subscription, not the total price of the subscription. This is very important since the rounding error changes how the next payments will be distributed. Next, on each split amount, a round down must be done. Then from the payed amount the split amounts are subtracted to get the rounding error. Now for the most complex part, we iterate through the subscriptions and try to apply the rounding error on the first subscription that still has debt, and apply the maximum amount of the rounding error that we can on that subscription(without over paying). If there is anything left, move to the next subscription and try to apply whatever is left. Repeat until nothing is left of the rounding error. Let's see how this works out:

 **1st installment**

    Internet = 2 / 6 * 2 = 0.66
    TV = 2 / 6 * 2 = 0.66
    Phone = 2 / 6 * 2 = 0.66
    Error = 2 - (0.66 * 3) = 0.02 - add it to Internet subscription
    Internet = 0.66 + 0.02 = 0.68

**2nd installment**

    Internet = 0.68 + 2/4 * 1.32 = 0.68 + 0.66 = 1.34
    TV = 0.66 + 2 / 4 * 1.34 = 0.66 + 0.67 = 1.33
    Phone = 0.66 + 2 / 4 * 1.34 = 0.66 + 0.67 = 1.33
    Error = 2 - ( 0.66 + 0.67 + 0.67 ) = 0.00

**3rd installment**

    Internet = 1.34 + 2/2 *0.66 = 1.34 + 0.66 = 2.00
    TV = 1.33 + 2 / 2 * 0.67 = 1.33 + 0.67 = 2.00
    Phone = 1.33 + 2 / 2 * 0.67 = 1.33 + 0.67 = 2.00

What happen here is that all the amounts are correct (as expected). The example failed to show how the error might need to be added to second or third subscription. But to prove it, just consider there is another subscription of just 1c that is first in the list (consider it an exercise for yourself).

And because you've been eager to see some code:

    Subscription internet = new Subscription { Due = 2m };
    Subscription tv = new Subscription { Due = 2m };
    Subscription phone = new Subscription { Due = 2m };
    
    List subscriptions = new List { internet, tv, phone };
    
    DistributePayment(subscriptions, 2m);
    
    //and the method
    void DistributePayment(List subscriptions, decimal amount)
    {
    	//first distribute the payments
    	decimal appliedAmount = 0m;
    	decimal totalDue = subscriptions.Sum(x => x.Due);
    
        foreach (Subscription subscription in subscriptions)
    	{
    		decimal calculatedAmount = RoundDown(amount / totalDue * subscription.Due);
    		subscription.Due -= calculatedAmount;
    		appliedAmount += calculatedAmount;
    	}
        //now distribute the error (if any)
    	decimal error = amount - appliedAmount;
    	foreach (Subscription subscription in subscriptions)
    	{
    		if (error == 0m) break;
    		if (subscription.Due > 0m)
    		{
    			decimal maxApply = Math.Min(error, subscription.Due);
    			subscription.Due -= maxApply;
    			error -= maxApply;
    		}
    	}
    }
    
    decimal RoundDown(decimal value)
    {
    	return Math.Floor(value * 100m) / 100m;
    }

Yes, that might sound overkill, but for a serious financial application it's a must. Of course you might need to adjust the algorithm to some specific requirements, but the rule of thumb is: don't loose cents and don't gain cents.If you don't respect that you end up with customers having a credit or debit of 1 and more cents. The amount of rounding error you might have (in smallest currency) is number of subscriptions - 1.

P.S. Never use double or float for representing money, always use decimal. You can google for the reasons.
