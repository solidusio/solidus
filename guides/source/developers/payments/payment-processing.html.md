# Payment processing

Solidus does not process payments. Instead, it relies on [payment service
providers][psp] (or PSPs) like Stripe or Braintree. So, in order to process
payments, your [payment methods][payment-methods] should first integrate with,
and send payment data to, your payment service provider.

The `Spree::Payment` record contains most of the logic that depends on an
integration with a PSP. (Note that the critical functionality has been isolated
in the [`Spree::Payment::Processing` module][spree-payment-processing].)

The `Spree::Payment#state` is used to document the state of the payment, and
whether the payment has been captured, voided, cancelled, etc. by the PSP.

[payment-methods]: payment-methods.html
[payment-service-providers]: payment-service-providers.html
[psp]: https://en.wikipedia.org/wiki/Payment_service_provider

## Interfacing with a payment service provider

When you set up your own payment methods, you need it to integrate with a payment
service provider. While you can create an integration in any way that you want,
you may want to note the following conventions set up by Solidus's
`Spree::PaymentMethod` model and the `Spree::Payment::Processing` module:

- `Spree::PaymentMethod` has a similar interface to API provided by the
  [active_merchant][active-merchant] gem.
- The `Spree::PaymentMethod` class uses its `gateway` method to read a hash of
  options that are provided by the payment service provider. See [Gateway
  options](#gateway-options) for more information about this.
- Then, in your own payment method, can call the `gateway` method and send this
  information to the payment service provider.

[active-merchant]: https://github.com/activemerchant/active_merchant

## Gateway options

The `Spree::Payment::Processing` class provides a `gateway_options` method. It
uses the current `Spree::Payment` object and the order it is associated to
provide a hash with relevant order information that can be sent to your payment
service provider.

For every gateway action, a list of gateway options are passed through:

- `email` and `customer`: The email address associated with the `Spree::Order`.
- `ip`: The last IP address for the order.
- `order_id`: The `Spree::Order`'s `number` attribute, as well as the
  `identifier` for each payment associated with the order. These are generated
   when the payment is first created.
- `originator`: The `Spree::Payment` itself.
- `shipping`: The total shipping cost for the order.
- `tax`: The total tax cost for the order.
- `subtotal`: The item total for the order.
- `discount`: The promotional discount total for the order.
- `currency`: The three-letter currency code for the order.
- `billing_address`: A hash containing `Spree::Address` being used as the
  shipping address for the order.
- `shipping_address`: A hash containing `Spree::Address` being used as the
  billing address for the order.

## The process! method

Payment processing depends on the logic of the `Spree::Payment#process!`, which
is defined in the [`Spree::Payment::Processing`
module][spree-payment-processing] and included on the `Spree::Payment` class.

Note that the `process!` method has many conditionals and different outcomes
depending on the status of the current `Spree::Payment`, the payment source, and
the way the `Spree::PaymentMethod` is configured.

In summary, the `process!` method processes the payment in one of the following
ways:

- If the `Spree::PaymentMethod`'s `auto_capture` attribute is set to `true`,
  `purchase!` is called, meaning the payment is authorized and captured. This
  occurs even if the payment's state is already `completed`.
- If the `Spree::PaymentMethod`'s `auto_capture` attribute is set to `false`,
  then the payment is authorized but not captured. This occurs even if the
  payment's state is already `completed`.

Note that `completed` payments can also transition to `processing`. Calling
`process!` on a completed payment attempts to re-`authorize!` and re-`purchase!`
the payment.

### If process! cannot complete

Payments cannot be processed using the `process!` method in a few circumstances:

- There is no `Spree::PaymentMethod` for the current payment.
- The `Spree::PaymentMethod` does not require a payment source.
- The `Spree::PaymentMethod`'s `auto_capture` attribute is set to `false`, and
  the payment is already authorized.
- The current payment is in the `processing` state.

The `process!` method cannot continue and raises an exception in the following
cases:

- The [payment source][payment-sources] is missing or invalid.
- The current payment is in a state that cannot transition to `processing`. (For
  example, its state is already `failed`, `void`, or `invalid`.)

[payment-sources]: payment-sources.html

## Processing walkthrough

This section goes into more detail of the steps taken to process a payment.

1. If a completed `Spree::Order`'s `#payment_required?` method returns `true`,
   the `process!` method is called and Solidus attempts to fulfill the payment.
2. If the payment's associated `Spree::PaymentMethod` requires a payment source,
   and the payment's `source_type` and `source_id` attributes reference a valid
   payment source, Solidus attempts to process the payment.
3. If the payment's associated `Spree::PaymentMethod` is configured to
   auto-capture payments (its `auto_capture` attribute is set to `true`), the
   `purchase!` method is called. Otherwise, only the `authorize!` method is
   called. Both of these methods should send information to the payment service
   provider See [The `authorize!` and `purchase!`
   methods](#the-authorize-and-purchase-methods) section for more information.
4. Payments need to be authorized and processed by your payment service provider
   before Solidus can finish processing your payments. How the `authorize!` and
   `purchase!` methods operate depends on how the `Spree::PaymentMethod` is
   implemented and which payment service provider is being used. Your payment
   service provider can either accept or reject the customer's payment.
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

[payment-states]: ../orders/payment-states.html

## The authorize! and purchase! methods

The `Spree::Payment::Processing` model has an `authorize!` and a `purchase!`
method that are used to interact with the payment service provider that is
configured for the current `Spree::PaymentMethod`. Each `Spree::Payment` stores
a hash of [gateway options](#gateway-options) that you can send to your payment
service provider.

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

[spree-payment-processing]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment/processing.rb
