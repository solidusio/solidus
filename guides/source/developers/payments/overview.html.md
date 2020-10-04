# Overview

Solidus has a flexible payments system that allows multiple payment methods to
be used during checkout.

The logic for processing payments is decoupled from Solidus's orders system.
This allows you to easily define your own payment methods with custom
processing logic.

The payments system has many moving parts. The following lists summarize the
essential parts of the payments system:

1. **Payment service providers**. Before your store can have a functional
   payments system, you need create an account with a payment service provider
   Braintree or Stripe.
2. **Payment methods**. A store may have multiple `Spree::PaymentMethod`s
   configured. Payment methods send payment information to a payment service
   provider.
3. **Payments**. After a customer submits their payment details for an order, a
   new `Spree::Payment` object is created.
4. **Payment sources**. `Spree::Payment`s can have a payment source. The source
   depends on the payment method that is used. For example, the payment source
   could be a `Spree::CreditCard`, `Spree::StoreCredit`, or a non-`Spree` model
   provided by your payment service provider integration.
5. **Payment processing**. Once an order is complete, a payment can be
   processed. At this point, the `Spree::Payment::Processing` class calls on
   `Spree::PaymentMethod` and attempts to capture the payment.

The complexity of your store's payments system depends on the payment gateways
that you use and the amount of payment methods that you need to support.

The rest of this article summarizes these parts of the system.

## Payment service providers (PSPs)

In order for you to successfully process payments, your  `Spree::PaymentMethod`s
need to send information to a [payment service provider][psp] (PSP).

The Solidus community has created a number of Solidus extensions to connect you
popular PSPs like Braintree, Adyen, Affirm, and Paybright.

Typically, PSP integrations use the `Spree::PaymentMethod` base class to build
out to the PSP's specifications and API.

Solidus is not built to process payments by itself, and it does not include any
integrations for popular PSPs. You must install an extension or create your own
integration.

<!-- TODO:
  # Once an article about payment service providers is merged, uncomment this
  link.

  For more information about payment service providers in Solidus, see the
  [Payment service providers][payment-service-providers] article.

  [payment-service-providers]: payment-service-providers.html
-->

[psp]: https://en.wikipedia.org/wiki/Payment_service_provider

## Payment methods

In Solidus, each `Spree::PaymentMethod` represents a way that your store chooses
to accept payments. For example, you may want to set up separate payment methods
for PayPal payments and credit card payments.

Solidus does not include working payment methods by default. Typically, you need
to integrate your payment method with a [payment service
provider](#payment-service-providers-psps).

Solidus includes bogus credit card methods for testing, a basic
`Spree::PaymentMethod::CreditCard` class that you can use for modeling your own
credit card payment methods, and some other basic payment methods.

For more information, see the [Payment methods][payment-methods] article.

[payment-methods]: payment-methods.html

## Payments

The `Spree::Payment` model in Solidus tracks payments. A new payment is created
once the customer has submitted their payment details during checkout.

Payments relate to a specific `Spree::Order`, as well as one of your available
`Spree::PaymentMethod`s and a payment source (which could be a
`Spree::CreditCard`, a `Spree::StoreCredit` or some other non-`Spree` model).

Note that a payment being created does not mean that a payment has been made
successfully. The `Spree::Payment` model has a state machine that tracks the
status of a payment. Once the payment is processed by your payment service
provider, the state could become `complete`, `failed`, `void`, and so on.


<!-- TODO:
  # Once a Spree::Payments article is merged, uncomment this link.

  For more information about payments, see the [Payments][payments] article.
-->

[payments]: payments.html

## Payment sources

Each `Spree::Payment` tracks a payment source. The payment source depends on the
types of payments you accept for each payment method.

For example, if you use Solidus's built-in `Spree::PaymentMethod::CreditCard`
payment method, the payment source class should always be set to
`Spree::CreditCard`.

Your payment methods may have more complex payment source classes. For example,
if you use the [`solidus_paypal_braintree`][solidus-paypal-braintree] gem,
payments made using your Braintree payment methods have the payment source
`SolidusPaypalBraintree::Source`. However, the `SolidusPaypalBraintree::Source`
class has a `payment_type` method that could have a value of `ApplePay`,
`CreditCard` or `PayPalAccount`.

<!-- TODO:
  # Once an article about payment sources is merged, uncomment this link.

  For more information about payment sources, see the [Payment
  methods][payment-sources] article.
-->

[payment-sources]: payment-sources.html
[solidus-paypal-braintree]: https://github.com/solidusio/solidus_paypal_braintree

## Payment processing

The `Spree::Payment::Processing` class's `process!` method can operate on
completed orders. It attempts to capture orders, invoking the customer's
selected `Spree::PaymentMethod` and sending payment details to the payment
service provider.

For more information about processing payments, see the [Payment
processing][payment-processing] article.

[payment-processing]: payment-processing.html
