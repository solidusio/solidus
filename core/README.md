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

## The User Sub-System
* `Spree::LegacyUser` - Default, non-production implementation of User class
intended to be extended or replaced.
* `Spree::UserClassHandle` - Configuration point for User model implementation.
* [solidus_auth_devise](https://github.com/solidusio/solidus_auth_devise) -
An offical, more robust implementation of a User class with Devise
integration.

# Developer Notes
## Testing

Create the test site

    bundle exec rake test_app

Run the tests

    bundle exec rake spec
