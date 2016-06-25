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

* [The Order Sub-System](https://github.com/bbuchalter/solidus/blob/core-readme/core/README.md#the-order-sub-system)
* [The User Sub-System](https://github.com/bbuchalter/solidus/blob/core-readme/core/README.md#the-user-sub-system)


## The Order Sub-System
* `Spree::Store` - Records store specific configuration such as store name and URL.
* `Spree::Order` - The customers cart until completed, then acts as
permenent record of the transaction.
* `Spree::LineItem` - Items placed in the cart at a particular price.

### [Spree::Store](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/store.rb)
`Spree::Store` provides the foundational ActiveRecord model for recording information
specific to your store such as its name, URL, and tax location. This model will
provide the foundation upon which [support for multiple stores](https://github.com/solidusio/solidus/issues/112)
hosted by a single Solidus implementation can be built.

### [Spree::Order](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/order.rb)
`Spree::Order` is the heart of the Solidus system, as it acts as the customer's
cart as they shop. Once an order is complete, it serves as the
permenent record of their purchase. It has many responsibilities:
* Records and validates attributes like `total` and relationships like
`Spree::LineItem` as an ActiveRecord model.
* Implements a customizable state machine to manage the lifecycle of an order.
* Implements business logic to provide a single interface for quesitons like
`checkout_allowed?` or `payment_required?`.
* Implements an interface for mutating the order with methods like
`create_tax_charge!` and `fulfill!`.

### [Spree::LineItem](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/line_item.rb)
`Spree::LineItem` is an ActiveRecord model which records which `Spree::Variant`
a customer has chosen to place in their order. It also acts as the permenent
record of the customer's order by recording relevant price, taxation, and inventory
concerns. Line items can also have adjustments placed on them as part of the
promotion system.

### [Spree::Address](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/address.rb)
`Spree::Address` provides the foundational ActiveRecord model for recording and
validating address information for `Spree::Order`, `Spree::Shipment`,
`Spree::UserAddress`, and `Spree::Carton`.

## The User Sub-System
* `Spree::LegacyUser` - Default, non-production implementation of User class
intended to be extended or replaced.
* `Spree::UserClassHandle` - Configuration point for User model implementation.
* [solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise) -
An offical, more robust implementation of a User class with Devise
integration.

### [Spree::LegacyUser](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/legacy_user.rb)
Solidus to provides a simple, default implementation of a User class in core,
via `Spree::LegacyUser`. *It is not suitable for production use*.

### [Spree::UserClassHandle](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/user_class_handle.rb)
`Spree::UserClassHandle` allows you to configure your own implementation of a
User class or use an extnesion like `solidus_auth_devise`.

## [solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise)
Provides a more robust implementation of a User class with Devise
integration, and is compatible with `solidus_frontend`.

# Developer Notes
## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
