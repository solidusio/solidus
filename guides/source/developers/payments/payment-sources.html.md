# Payment sources

<!-- TODO:
  This article is a stub. We could go deeper into how payment sources work.
-->

Each `Spree::Payment` object has optional `source_type` and `source_id`
attributes that point to a payment source model. The listed source type is
supplied by the `Spree::PaymentMethod` being used.

Solidus includes some payment sources such as `Spree::CreditCard` and
`Spree::StoreCredit`. However, your [payment method][payment-methods] could
define any custom payment source in its `payment_source_class` method.

[payment-methods]: payment-methods.html

## Credit cards

If your [payment processing][payment-processing] integration uses the
`Spree::CreditCard` class for its payment source, take note that this model does
not store all of the payment details. Solidus only collects enough data to allow
customers to verify which credit card is being used.

All the credit card data that you collect should be immediately sent through
a form to the payment service provider. Your databases should not store a
customer's complete credit card data for any amount of time.

Whenever you store sensitive customer data, you risk a PCI compliance violation.
We recommend using the `Spree::CreditCard` class as an example of responsibly
storing customer data. See the [PCI Security Standards][pci] website for more
information.

[pci]: https://www.pcisecuritystandards.org
[payment-processing]: payment-processing.html
