# Payments

The `Spree::Payment` model in Solidus tracks payments. A new payment is created
once the customer has submitted their payment details during checkout. Once a
payment's `state` is marked as `completed`, it counts against a `Spree::Order`'s
total.

Payments relate to a specific `Spree::Order`, as well as one of your available
`Spree::PaymentMethod`s and a payment source (which could be a
`Spree::CreditCard`, a `Spree::StoreCredit` or some other non-`Spree` model).

`Spree::Payment` objects have the following attributes:

- `amount`: The payment amount.
- `order_id`: The ID for the associated `Spree::Order`.
- `source_type` and `source_id`: The model being used as the payment source and
  its ID. For example, `Spree::CreditCard`. See the [Payment
  sources][payment-sources] article for more information.
- `payment_method_id`: The ID for the associated `Spree::PaymentMethod`.
- `state`: The payment's current state. See [Payment states](#payment-states)
  for more information.
- `response_code`: A generalized response code or token sent by the payment
  service provider. You should configure this based on the payment service
  provider you are using. For example, this could be used to display a Stripe
  transaction token in case it needs to be referenced later on.
- `avs_response`: The AVS response code sent by the payment service provider.
  See [Response codes](#response-codes) for more information.
- `number`: A unique number to identify the current payment. See [Payment
  identifiers](#payment-identifiers) for more information.
- `cvv_response_code` and `cvv_response_message`: The CVV2 response sent by the
  payment service provider. See [Response codes](#response-codes) for more
  information.

[payment-sources]: payment-sources.html

## Payment identifiers

When a `Spree::Payment` is created, a unique, eight-character identifier is
generated for the `number` attribute. It should look something like this:
`2EYGNY8D`. This is used when sending the payment details to the [payment
service provider][payment-service-providers].

While some payment service providers may not require a payment identifier, other
services may require or recommend them. In the past, some services have
erroneously reported duplicate payments when not recording a payment identifier.

## Response codes

`Spree::Payment`s store AVS and CVV2 response codes that are sent back from the
payment service provider. These response codes help you classify payments as
risky, non-risky, or invalid. See [PayPal's list of AVS and CVV response
codes][response-codes] to learn more about what these codes mean.

[response-codes]: https://developer.paypal.com/docs/classic/api/AVSResponseCodes/

## Payment states

A `Spree::Payment`'s `state` attribute changes before and after it is sent to
the payment service provider. Here is an explanation for each potential state:

- `checkout`: The `Spree::Order` is not yet complete.
- `processing`: The payment is being processed by the payment service provider.
  This is a temporary state intended to prevent the double-submission of a
  payment.
- `pending`: The payment service provider has processed the payment, but the
  payment is not yet captured.
- `failed`: The payment was rejected by the payment service provider.
- `invalid`: The payment is invalid and needs to be reattempted.
- `void`: The payment should not be counted against the order.
- `completed`: The payment is completed.

Note that only payments in the `completed` state count against the order total.

### Payment event methods

The `Spree::Payment` model includes event methods you can use to transition from
state to state:

- `started_processing`
- `failure`
- `pend`
- `complete`
- `void`
- `invalidate`

<!-- TODO:
  This subarticle could use more verbose definitions/descriptions.
-->
