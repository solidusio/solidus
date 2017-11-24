# Payment Methods

Payment methods represent the different options a customer has for making a
payment. Most sites will accept credit card payments through a payment gateway,
but there are other options. Solidus also comes with built-in support for a
Check payment, which can be used to represent any offline payment.

 There are also third-party extensions that provide support for some other payment options such as:
* [`solidus_braintree`](https://github.com/solidusio/solidus_braintree) for Braintree v.zero.
* [`solidus_braintree_paypal`](https://github.com/solidusio/solidus_paypal_braintree) for Braintree provided payment methods like PayPal, Apple Pay and credit cards
* [`solidus_adyen`](https://github.com/StemboltHQ/solidus-adyen) for Adyen provided payment methods
* [`solidus_affirm`](https://github.com/StemboltHQ/solidus_affirm) for Affirm provided payment methods
* [`solidus_klarna_payments`](https://github.com/bitspire/solidus_klarna_payments)
* [`solidus_paybright`](https://github.com/StemboltHQ/solidus_paybright)
* [`solidus_culqi`](https://github.com/ccarruitero/solidus_culqi) for process credit cards with Culqi.
* [`solidus_payu_latam`](https://github.com/ccarruitero/solidus_payu_latam) for process credit cards with PayuLatam.

A `PaymentMethod` can have the following attributes:

* `type`: The subclass of `Spree::PaymentMethod` this payment method represents. Uses rails single table inheritance feature.
* `name`: The visible name for this payment method
* `description`: The description for this payment method
* `active`: Whether or not this payment method is active. Set it `false` to hide it in frontend.
* `available_to_users`: Determines if the payment method can be visible for users.
* `available_to_admin`: Determines if the payment method can be visible for admin.
* `auto_capture`: Determines if a payment will be automatically captured (true) or only authorized (false) during the processing of the payment.

You can have more attributes, according the Payment Method type that you chose.

## Auto-Capturing

If you haven't set the `auto_capture` attribute for your payment method, it
takes `Spree::Config[:auto_capture]` preference for that option.
Otherwise the `auto_capture` attribute is taken.
