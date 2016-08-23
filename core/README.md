Summary
------
Solidus Core provides the essential e-commerce data models upon which the
Solidus system depends.

Core Models
-----------
Solidus implements over 200 [models](https://github.com/solidusio/solidus/tree/master/core/app/models/spree),
and thus a deep inspection of each in this README would be overkill. Instead,
let's take a quick look at the fundamental models upon which all else depend.
Currently, these models remain in the Spree namespace as part of the legacy of
[forking Spree](https://solidus.io/blog/2015/10/28/future-of-spree.html).

## NOTE: Documentation is a work in progress
The documentation of Solidus Core is still in progress. Contributions following
this form are welcome and encouraged!

* [The Order Sub-System](#the-order-sub-system)
* [The User Sub-System](#the-user-sub-system)
* [The Payment Sub-System](#the-payment-sub-system)
* [The Inventory Sub-System](#the-inventory-sub-system)
* [The Shipments Sub-System](#the-shipments-sub-system)

## The Order Sub-System
* `Spree::Store` - Records store specific configuration such as store name and URL.
* `Spree::Order` - The customers cart until completed, then acts as
permenent record of the transaction.
* `Spree::LineItem` - Variants placed in the order at a particular price.

## The User Sub-System
* `Spree::LegacyUser` - Default implementation of User.
* `Spree::UserClassHandle` - Configuration point for User model implementation.
* [solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise) -
An offical, more robust implementation of a User class with Devise
integration.

## The Payment Sub-System
* `Spree::Payment` - Manage and process a payment for an order, from a specific
source (e.g. `Spree::CreditCard`) using a specific payment method (e.g
`Solidus::Gateway::Braintree`).
* `Spree::PaymentMethod` - An abstract class which is implemented most commonly
as a `Spree::Gateway`.
* `Spree::Gateway` - A concrete implementation of `Spree::PaymentMethod`
intended to provide a base for extension. See
https://github.com/solidusio/solidus_gateway/ for offically supported payment
gateway implementations.
* `Spree::CreditCard` - The default `source` of a `Spree::Payment`.

## The Inventory Sub-System
* `Spree::ReturnAuthorization` - Models the return of Inventory Units to
a Stock Location for an Order.
* `Spree::StockLocation` - Records the name and addresses from which stock items
are fulfilled in cartons.
* `Spree::InventoryUnit` - Tracks the state of line items' fulfillment.
* `Spree::ShippingRate` - Records the costs of different shipping methods for a
shipment and which method has been selected to deliver the shipment.
* `Spree::ShippingMethod` - Represents a means of having a shipment delivered,
such as FedEx or UPS.

## The Shipments Sub-System
* `Spree::Shipment` - An order's planned shipments including
tracking and cost. Shipments are fulfilled from Stock Locations.

Developer Notes
---------------
## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
