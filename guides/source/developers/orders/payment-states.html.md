# Payment states

<!-- TODO:
  This article is a stub. It may need to be merged with another orders article
  in the future.
-->

Typically, a `Spree::Order` has one or multiple payments associated with it.
Because of this, the order object has a `payment_state` attribute that tracks
against all of the payments associated with the order.

For example, if your customer has $20 on store credit but their order comes to
$40, they need to use two payment methods in order to pay for the order: the
`Spree::StoreCredit` payment method and one of the other available payment
methods.

A `Spree::Order` can have one of the following `payment_state`s:

The following is a list of the available payment states:

- `balance_due`: This state indicates that a payment on the order is required.
  The order's `payment_total` value is less than its `total` value.
- `failed`: This state indicates that the most recent payment for the order
  failed.
- `credit_owed`: This state indicates that the order has been paid for in excess
  The order's `payment_total` value is greater than its `total` value.
- `paid`: This state indicates that the order has been paid for in full and no
  credited is owed.
- `void`: This state indicates that the order has been canceled. No credit is
  owed, no balance is due, and the order has not been paid for.

For more information about `Spree::Payment`s and the Solidus payments system,
see the [Payments][payments] documentation.

[payments]: ../payments/overview.html
[payment-sources]: ../payments/payment-sources.html

## Completed payments

The `Spree::Order`'s `payment_state` can only be `paid` if the order has been
paid for in full and no credit is owed. This means that the order's
`payment_total` and `total` values are equal.

The following table outlines a `Spree::Order` with a `total` of $40.  It has
multiple payments and has a `payment_state` value of `balance_due`:

| Payment source type  | Amount | State         |
|----------------------|--------|---------------|
| `Spree::StoreCredit` | $20    | `completed`   |
| `Spree::CreditCard`  | $20    | `balance_due` |

And the next table outlines a `Spree::Order` that has a `payment_state` value of
`paid`:

| Payment source type  | Amount | State         |
|----------------------|--------|---------------|
| `Spree::StoreCredit` | $20    | `completed`   |
| `Spree::CreditCard`  | $20    | `completed`   |

Finally, this table also outlines a `Spree::Order` with a `payment_state` of
`paid` even though it has failed payments:

| Payment source type  | Amount | State         |
|----------------------|--------|---------------|
| `Spree::StoreCredit` | $20    | `completed`   |
| `Spree::CreditCard`  | $20    | `invalid`     |
| `Spree::CreditCard`  | $20    | `failed`      |
| `Spree::CreditCard`  | $20    | `paid`        |

## Credit owed

If an order has multiple payments and the customer over-pays for an order, the
order's `payment_state` changes to `credit_owed`.

In order to get the order to a `paid` status, the customer should be refunded so
that the order is zeroed out.

You can generate a `Spree::Refund` for any payment on the order. The refund can
equal either the full payment amount or just a part of the full payment.

For more information, see the [Refunds][refunds] documentation.

[refunds]: ../payments/refunds.html

## Checking payment states

You can check the state of the of all of the payments associated with an order
using the `payment_state` method:

```ruby
Spree::Order.find(1).payment_state
# => "balance_due"
```

The `payment_state` method can be very useful if you have built out your own
integrations with a payment service provider. For example, a sudden increase in
orders with `payment_state` of `failed` may indicate a problem with your
integration. It may also affect your store's customer satisfaction rate.

<!-- TODO:
  Link to documentation about logging once it has been merged. payment_state
  would be a useful thing to log.
-->

<!-- TODO:
  Link to payment service providers article in this article once it is merged.
-->

[payment-service-providers]: ../payments/payment-service-providers.html
