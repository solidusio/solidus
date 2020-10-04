Summary
------
Solidus Core provides the essential ecommerce data models upon which the
Solidus system depends.

Core models
-----------
Solidus implements over 200 [models](https://github.com/solidusio/solidus/tree/master/core/app/models/spree),
and thus a deep inspection of each in this README would be overkill. Instead,
let's take a quick look at the fundamental models upon which all else depend.
Currently, these models remain in the Spree namespace as part of the legacy of
[forking Spree](https://solidus.io/blog/2015/10/28/future-of-spree.html).

## NOTE: Documentation is a work in progress
The documentation of Solidus Core is still in progress. Contributions following
this form are welcome and encouraged!

* [Order sub-system](#order-sub-system)
* [User sub-system](#user-sub-system)
* [Payment sub-system](#payment-sub-system)
* [Inventory sub-system](#inventory-sub-system)
* [Shipments sub-system](#shipments-sub-system)

## Order sub-system
* `Spree::Store` - Records store specific configuration such as store name and URL.
* `Spree::Order` - The customers cart until completed, then acts as
permanent record of the transaction.
* `Spree::LineItem` - Variants placed in the order at a particular price.

## User sub-system
* `Spree::LegacyUser` - Default implementation of User.
* `Spree::UserClassHandle` - Configuration point for User model implementation.
* [solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise) -
An official, more robust implementation of a User class with Devise
integration.

## Payment sub-system
* `Spree::Payment` - Manage and process a payment for an order, from a specific
source (e.g. `Spree::CreditCard`) using a specific payment method (e.g
`Solidus::Gateway::Braintree`).
* `Spree::PaymentMethod` - A base class which is used for implementing payment methods.
* `Spree::PaymentMethod::CreditCard` - An implementation of a `Spree::PaymentMethod` for credit card payments.
See https://github.com/solidusio/solidus_gateway/ for officially supported payment method implementations.
* `Spree::CreditCard` - The `source` of a `Spree::Payment` using `Spree::PaymentMethod::CreditCard` as payment method.

## Inventory sub-system
* `Spree::ReturnAuthorization` - Models the return of Inventory Units to
a Stock Location for an Order.
* `Spree::StockLocation` - Records the name and addresses from which stock items
are fulfilled in cartons.
* `Spree::InventoryUnit` - Tracks the state of line items' fulfillment.
* `Spree::ShippingRate` - Records the costs of different shipping methods for a
shipment and which method has been selected to deliver the shipment.
* `Spree::ShippingMethod` - Represents a means of having a shipment delivered,
such as FedEx or UPS.

## Shipments sub-system
* `Spree::Shipment` - An order's planned shipments including
tracking and cost. Shipments are fulfilled from Stock Locations.

Developer notes
---------------
## Testing

Run the tests:

```bash
bundle exec rspec
```
