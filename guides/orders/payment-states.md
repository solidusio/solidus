# Payment states

<!-- TODO:
  This article is a stub. It may need to be merged with another orders article
  in the future.
-->

Typically, a `Spree::Order` has one or multiple payments associated with it.

For example, if your customer has $20 on store credit but their order comes to
$40, they need to use two payment methods in order to pay for the order: the
`Spree::StoreCredit` payment method and one of the other available payment
methods.

A `Spree::Order` can have one of the following `payment_state`s:

The following is a list of the available payment states:

- `balance_due`: This state indicates that a payment on the order is required.
- `failed`: This state indicates that at least one payment for the order failed.
- `credit_owed`: This state indicates that the order has been paid for in excess
  of its total.
- `paid`: This state indicates that the order has been paid for in full. All of
  the `Spree::Payment`s on the order have been satisfied.

For more information about `Spree::Payment`s and the Solidus payments system,
see the [Payments][payments] documentation.

[payments]: ../payments/overview.md

## Completed payments 

The `Spree::Order`'s `payment_state` can only be `paid` if each `Spree::Payment`
has a state of `completed`.

The following table outlines a `Spree::Order` with multiple payments that stile
has a `payment_state` value of `balance_due`:

| Payment source type  | Amount | State         |
|----------------------|--------|---------------|
| `Spree::StoreCredit` | $20    | `completed`   |
| `Spree::CreditCard`  | $20    | `balance`     |

And the next table outlines a `Spree::Order` with multiple payments that has a
`payment_state` value of `completed`:

| Payment source type  | Amount | State         |
|----------------------|--------|---------------|
| `Spree::StoreCredit` | $20    | `completed`   |
| `Spree::CreditCard`  | $20    | `completed`   |


## Checking payment states

You can check the state of the of all of the payments associated with an order
using the `payment_state` method:

```ruby
Spree::Order.find(1).payment_state
# => "balance_due"
```

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
