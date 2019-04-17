# Payment service providers

Solidus is not built to process payments by itself, and it does not include any
integrations for popular [payment service providers (PSPs)][psp]. You must
install a Solidus extension or create your own integration. 

[psp]: https://en.wikipedia.org/wiki/Payment_service_provider 

## Solidus extensions for payment processing

The Solidus extensions listed below give you access to some popular payment
service providers:

- [`solidus_braintree`][solidus-braintree] (Braintree v.zero)
- [`solidus_paypal_braintree`][solidus-paypal-braintree]
- [`solidus_adyen`][solidus-adyen]
- [`solidus_affirm`][solidus-affirm]
- [`solidus_klarna_payments`][solidus-klarna-payments]
- [`solidus_paybright`][solidus-paybright]
- [`solidus_culqi`][solidus-culqi]
- [`solidus_payu_latam`][solidus-payu-latam]

[solidus-affirm]: https://github.com/StemboltHQ/solidus_affirm
[solidus-adyen]: https://github.com/StemboltHQ/solidus-adyen
[solidus-braintree]: https://github.com/solidusio/solidus_braintree
[solidus-culqi]: https://github.com/ccarruitero/solidus_culqi
[solidus-klarna-payments]: https://github.com/bitspire/solidus_klarna_payments
[solidus-paybright]: https://github.com/StemboltHQ/solidus_paybright
[solidus-paypal-braintree]: https://github.com/solidusio/solidus_paypal_braintree
[solidus-payu-latam]: https://github.com/ccarruitero/solidus_payu_latam

## Sending payments to PSPs 

In order for you to successfully process payments, your payment methods need to
send information to a payment service provider. You can use the
`Spree::PaymentMethod` and `Spree::PaymentMethod::CreditCard` classes if you
need to build out your own integrations with a PSP.

### The Spree::PaymentMethod base class

Typically, PSP integrations use the `Spree::PaymentMethod` base class to build
out to the PSP's specifications and API.

Note that the `Spree::PaymentMethod` base class also has a similar interface to
the [`active_merchant`][active-merchant] gem.

[active-merchant]: https://github.com/activemerchant/active_merchant

For an example, see how the `solidus_paypal_braintree` gem builds its
[`SolidusPaypalBraintree::Gateway` class][solidus-paypal-braintree-gateway] class:
it sets its own preferences and overrides many of the methods originally defined
in `Spree::PaymentMethod`.

[solidus-paypal-braintree-gateway]: https://github.com/solidusio/solidus_paypal_braintree/blob/master/app/models/solidus_paypal_braintree/gateway.rb

### Spree::PaymentMethod::CreditCard

Solidus also provides a [`Spree::PaymentMethod::CreditCard`][credit-card-base]
class. While it is not a functional credit card-based payment method, it is a
good candidate as a base class for building your own credit card-based payment
methods.

You would need to extend or rewrite this class with your preferred PSP
integration.

[credit-card-base]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/payment_method/credit_card.rb
