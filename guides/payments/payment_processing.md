# Payment Processing

Payment processing in Spree supports many different gateways, but also attempts
to comply with the API provided by the [active_merchant](https://github.com/activemerchant/active_merchant) gem where possible.

## Gateway Options

For every gateway action, a list of gateway options are passed through.

* `email` and `customer`: The email address related to the order
* `ip`: The last IP address for the order
* `order_id`: The Order's `number` attribute, plus the `identifier` for each payment, generated when the payment is first created
* `originator`: the payment itself
* `shipping`: The total shipping cost for the order, in cents
* `tax`: The total tax cost for the order, in cents
* `subtotal`: The item total for the order, in cents
* `discount`: The promotional discount applied to the order, in cents
* `currency`: The 3-character currency code for the order
* `billing_address`: A hash containing billing address information
* `shipping_address`: A hash containing shipping address information

The billing address and shipping address data is as follows:

* `name`: The combined `first_name` and `last_name` from the address
* `address1`: The first line of the address information
* `address2`: The second line of address information
* `city`: The city of the address
* `state`: An abbreviated version of the state name or, failing that, the state name itself, from the related `State` object. If that fails, the `state_name` attribute from the address.
* `country`: The ISO name for the country. For example, United States of America is "US", Australia is "AU".
* `phone`: The phone number associated with the address

## Credit Card Data

Solidus stores only the type, expiration date, name and last four digits for the
card on your server. This data can then be used to present to the user so that
they can verify that the correct card is being used. All credit card data sent
through forms is sent through immediately to the gateways, and is not stored for
any period of time.

## Processing Walkthrough

When an order is completed in Solidus, each `Payment` object associated with the
order has the `process!` method called on it, unless `payment_required?` for the
order returns `false`, in order to attempt to automatically fulfill the payment
required for the order.

If the payment method requires a source, and the payment has a source associated
with it, then Solidus will attempt to process the payment. Otherwise, the
payment will need to be processed manually.

If the `PaymentMethod` object is configured to auto-capture payments, then the
`Payment#purchase!` method will be called, which will call
`PaymentMethod#purchase` like this:

```ruby
payment_method.purchase(<amount>, <source>, <gateway options>)
```

If the payment is *not* configured to auto-capture payments, the
`Payment#authorize!` method will be called, with the same arguments as the
`purchase` method above:

```ruby
payment_method.authorize(<amount>, <source>, <gateway options>)
```

How the payment is actually put through depends on the `PaymentMethod`
sub-class' implementation of the `purchase` and `authorize` methods.

The returned object from both the `purchase` and `authorize` methods on the 
payment method objects must be an `ActiveMerchant::Billing::Response` object.
This response object is then stored (in YAML) in the `spree_log_entries` table.
Log entries can be retrieved with a call to the `log_entries` association on any
`Payment` object.

If the `purchase!` route is taken and is successful, the payment is marked as
`completed`. If it fails, it is marked as `failed`. If the `authorize` method is
successful, the payment is transitioned to the `pending` state so that it can be
manually captured later by calling the `capture!` method. If it is unsuccessful,
it is also transitioned to the `failed` state.

***
Once a payment has been saved, it also updates the order. This may trigger the
`payment_state` to change, which would reflect the current payment state of the
order. The possible states are:

* `balance_due`: Indicates that payment is required for this order
* `failed`: Indicates that the last payment for the order failed
* `credit_owed`: This order has been paid for in excess of its total
* `paid`: This order has been paid for in full.
***

!!!
You may want to keep tabs on the number of orders with a `payment_state` of
`failed`. A sudden increase in the number of such orders could indicate a
problem with your credit card gateway and most likely indicates a serious
problem affecting customer satisfaction. You should check the latest
`log_entries` for the most recent payments in the store if this is happening.
!!!

## Log Entries

Responses from payment gateways within Solidus are typically
`ActiveMerchant::Billing::Response` objects. When Solidus handles a response
from a payment gateway, it will serialize the object as YAML and store it in the
database as a log entry for a payment. These responses can be useful for
debugging why a payment has failed.

You can get a list of these log entries by calling the `log_entries` on any 
`Spree::Payment` object. To get the `Active::Merchant::Billing::Response` out of
these `Spree::LogEntry` objects, call the `details` method.

You can add [solidus_log_viewer](https://github.com/solidusio-contrib/solidus_log_viewer)
to get the logs next to the payments in the admin.
