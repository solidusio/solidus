# Payment states

<!-- TODO:
  This article is a stub. It may need to be merged with another orders article
  in the future.
-->

Any `Spree::Order` can have multiple payments associated with it. You can check
the state of the of all of the payments associated with an order using the
`payment_state` method:

```ruby
Spree::Order.find(1).payment_state
# => "balance_due"
```

A `Spree::Order` can have one of the following `payment_state`s:

The following is a list of the available payment states:

- `balance_due`: This state indicates that a payment on the order is required.
- `failed`: This state indicates that at least one payment for the order failed.
- `credit_owed`: This state indicates that the order has been paid for in excess
  of its total.
- `paid`: This state indicates that the order has been paid for in full. All of
  the `Spree::Payment`s on the order have been satisfied.L

The `payment_state` method can be very useful if you have built out your own
integrations with a payment service provider. For example, a sudden increase in
orders with with `payment_state` of `failed` may indicate a problem with your
integration. It may also affect your store's customer satisfaction rate.

<!-- TODO:
  Link to documentation about logging once it has been merged. payment_state
  would be a useful thing to log.
-->

<!-- TODO:
  Link to payment service providers article in this article once it is merged.
-->

[payment-service-providers]: ../payments/payment-service-providers.html
