# Payment methods

In Solidus, each `Spree::PaymentMethod` represents one way that your store
chooses to accept payments. For example, you may want to set up separate payment
methods for PayPal payments and credit card payments.

You can inherit the [`Spree::PaymentMethod` base class][payment-method-base]
when you build your own integration for a payment service provider. <!-- For
more information about Solidus and payment service providers, see the [Payment
service providers][payment-service-providers] article. -->

`Spree::PaymentMethod` objects have the following attributes:

- `type`: The subclass of `Spree::PaymentMethod` that this payment method
  represents.
- `name`: The display name for this payment method.
- `description`: The description for this payment method.
- `auto_capture`: Determines whether a payment should be captured (`true`) or
  only authorized (`false`) during payment processing. For more information, see
  [Auto-capture](#auto-capture).
- `preferences`: A hash of preferences and their current settings for the
  current payment method. The available preferences can be changed by setting a
  different `preference_source`.
- `preference_source`: Sets the source for the `preferences` hash content. Your
  payment method may require additional preferences for interfacing with a
  payment service provider. See [Preferences](#preferences) for more
  information.
- `active`: Sets whether the payment method is active. Set this to `false` to
  hide the payment method from customers.
- `available_to_users`: Determines if the payment method is visible to users.
- `available_to_admin`: Determines if the payment method is visible to
  administrators.

<!-- TODO:
  Uncomment the link to the payment service providers article once it is merged.
-->

[payment-method-base]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment_method.rb
[payment-service-providers]: payment-service-providers.html

## Preferences

Each payment method has a `preferences` attribute that stores settings as a
hash. The preference values get passed to the payment service provider, so your
payment method may require additional preferences (like public and private API
keys).

The base `Spree::PaymentMethod` class has just two preferences:

- `:server`: The name of your server. This defaults to `"test"`.
- `:test_mode`: Sets whether the payment method can be used for test payments.

## Auto-capture

All `Spree::Payment` objects need to be captured before they are sent to the
payment service provider for [processing][payment-processing]. If the
`auto_capture` attribute for a payment method is set to `false`, the
administrator must manually capture payments. However, you can set any payment
method to auto-capture payments.

[payment-processing]: payment-processing.html

### Application-wide auto-capture default

If you have not set the `auto_capture` attribute for a payment method, it
defaults to the value of your store's `Spree::Config[:auto_capture]` preference.

## Set a payment source class

The `Spree::PaymentMethod` base class has a method called
`payment_source_class`. It sets the payment source that should be associated
with your payment method. When you are creating your own payment method, you
need to define a `payment_source_class` (even if it is `nil`).

Solidus provides payment sources such as `Spree::CreditCard` and
`Spree::StoreCredit`. However, payment methods included in Solidus extensions
(like [`solidus_paypal_braintree`][solidus-paypal-braintree]) could use a
completely custom payment source. (For example, the `solidus_paypal_braintree`
gem uses `SolidusPaypalBraintree::Source` as the payment source for all
payments.)

[solidus-paypal-braintree]: https://github.com/solidusio/solidus_paypal_braintree

## Built-in payment methods

Solidus does not include working payment methods by default. However, it does
offer basic payment methods you can use to help you build out your own
integration with a payment service provider.

These payment methods are provided by Solidus:

- `Spree::PaymentMethod::Check`: A class for processing payments from checks.
- `Spree::PaymentMethod::StoreCredit`: A class for processing payments from
  a user's existing `Spree::StoreCredit`.
- `Spree::PaymentMethod::CreditCard`: A base class for other typical credit
  card-based payment methods. It uses `Spree::CreditCard` as a payment source.

Solidus also provides bogus credit card payment methods for testing purposes:

- `Spree::PaymentMethod::BogusCreditCard`
- `Spree::PaymentMethod::SimpleBogusCreditCard`

You can view the source code for all of Solidus's provided payment methods in
the [`/core/app/models/spree/payment_method/`][payment-method-source].

The simple bogus credit card method does not support payment profiles.[^1]

[payment-method-source]: https://github.com/solidusio/solidus/tree/master/core/app/models/spree/payment_method

[^1]: A payment profile is a record that pairs a specific customer with a
  specific credit card. Some payment gateway providers or billing systems use
  payment profiles while others do not.
