# Payment processing

Solidus does not process payments. Instead, it relies on payment service
providers like Stripe or Braintree. So, in order to process payments, your
[`Spree::PaymentMethod`s][payment-methods] should first integrate with, and send
payment data to, your payment service provider.

While the `Spree::Payment` model executes much of the processing logic and
manages the state of the payment (before and after processing), note that it
inherits from the [`Spree::Payment::Processing`
class][spree-payment-processing].

<!-- TODO:
  Add links to payment service providers article in this introduction once it is
  merged.
-->

[payment-methods]: payment_method.md
[payment-service-providers]: payment-service-providers.md
[spree-payment-processing]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment/processing.rb

## The process! method

Payment processing depends on the `process!` method included in the
`Spree::Payment::Processing` class.

Note that the `process!` method has many conditionals and different outcomes
depending on the status of the current `Spree::Payment`, the payment source, and
the way the `Spree::PaymentMethod` is configured.

In summary, the `process!` method processes the payment in one of the following
ways:

- If the `Spree::PaymentMethod`'s `auto_capture` attribute is set to `true`,
  `purchase!` is called, meaning the payment is authorized and captured. This
occurs even if the payment's state is already `completed`.
- If the `Spree::PaymentMethod`'s `auto_capture` attribute is set to `false`,
  then the payment is authorized but not captured. This occurs even if if the
  payment's state is already `completed`.

Note that `completed` payments can transition to `processing`. Calling
`process!` on a completed payment attempts to re-authorize and re-purchase the
payment.

### If process! cannot complete

Payments cannot be processed using the `process!` method in a few circumstances:

- There is no `Spree::PaymentMethod` for the current payment.
- The `Spree::PaymentMethod` does not require a payment source.
- The `Spree::PaymentMethod`'s 'auto_capture' attribute is set to `false`, and
  the payment is already authorized.
- The current payment is in the `processing` state.

The `process!` method cannot continue and raises an exception in the following
cases:

- The payment source is missing or invalid.
- The current payment is in a state that cannot transition to `processing`. (For
  example, its state is already `failed`, `void`, or `invalid`.)

<!-- TODO:
  Add links to payment sources article in this section once it is merged.
-->

[payment-sources]: payment-sources.md

## Processing walkthrough

This section goes into more detail of the steps taken to process a payment.

1. If a completed `Spree::Order`'s `payment_required?` method returns `true`,
   the `process!` method is called and Solidus attempts to fulfill the payment.
2. If the payment's associated `Spree::PaymentMethod` requires a payment source,
   and the payment's `source_type` and `source_id` attributes reference a valid
   payment source, Solidus attempts to process the payment.
3. If the payment's associated `Spree::PaymentMethod` is configured to
   auto-capture payments (its `auto_capture` attribute is set to `true`), the
   `purchase!` method is called. Otherwise, only the `authorize!` method is
   called. See [The `authorize!` and `purchase!`
   methods](#the-authorize-and-purchase-methods) section for more information.
4. Payments need to be authorized and processed by your payment service provider
   before Solidus can finish processing your payments. How the `authorize!` and
   `purchase!` methods operate depends on how the
   `Spree::PaymentMethod` is implemented and which payment service provider is
   being used. Your payment service provider can either accept or reject the
   customer's payment.
5. After you receive a response back from the payment service provider, you
   should have response objects that tell you whether the payment can be
   authorized and captured successfully. If the `purchase!` method is
   successful, the `Spree::Payment`'s `state` transitions to `completed`.
   Otherwise, it transitions to `failed`.
6. If the auto-capture is not available, then the payment can be manually
   captured using the `capture!` method.
7. Once a payment has been saved, the associated `Spree::Order` is updated. At
   this point, the `Spree::Order`'s current `payment_state` may change. For more
   information about the `payment_state` on an order, see the [Payment
   states][payment-states] article.

[payment-states]: ../orders/payment-states.md

### The authorize! and  purchase! methods

If the `Spree::PaymentMethod` object is configured to auto-capture payments, the
`Spree::Payment::Processing#purchase!` method is called, which then calls the
`SpreePaymentMethod#purchase` like this:

```ruby
payment_method.purchase(<amount>, <source>, <gateway options>)
```

If the payment is not configured to auto-capture payments, the
`Spree::Payment::Processing#authorize!` method is called with the same arguments
as the `purchase` method above:

```ruby
payment_method.authorize(<amount>, <source>, <gateway options>)
```
