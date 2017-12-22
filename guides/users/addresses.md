# Addresses

The `Spree::Address` model is used to track address information for customers.
Addresses are consumed by `Spree::Order`s, `Spree::Shipment`s, and
`Spree::Carton`s.

If your store uses the [`solidus_auth_devise`][solidus-auth-devise] gem,
customers belong to the `Spree::User` model. A customer may have multiple
addresses. For example, it is typical for customers to have separate billing and
shipping addresses.

You may want to find all of the addresses associated with a `Spree::User`:

```ruby
Spree::User.find(1).addresses
```

`Spree::Address` objects have the following attributes:

- `firstname`: The first name for the person at this address.
- `lastname`: The last name for the person at this address.
- `address1` and `address2`: The street address (with an optional second line).
- `city`: The city where the address is.
- `zipcode`: The postal code.
- `phone` and `alternative_phone`: The customer's phone number(s).
- `state_name`: If the customer uses a region name that doesn't correspond with
  a country's list of states, the address can store the user-entered
- `state_name` as a fallback. 
- `alternative_phone`: The alternative phone number.
- `company`: A company name.
- `state_id` and `country_id`: IDs for the `Spree::State` and `Spree::Country`
  objects associated with the customer's entered address. These are used to
  determine the customer's zone, which determines applicable taxation and
  shipping methods.

<!-- TODO:
  Once the locations (zones) documentation is merged, we need to link to that
  documentation from this article.
-->

[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise

## Countries and states 

Countries and states can affect both taxation and shipping on orders. So, an
address must always link to a `Spree::Country` object. Because some countries do
not have associated `Spree::State`s, a state object is not required.

If the user-entered state does not correspond with a `Spree::Country`'s
associated states, then the `state_name` attribute is used to record the state
name.

If you use the `solidus_frontend` gem to provide your store's frontend, the
state field is hidden if the customer's country does not have `Spree::State`s
associated with it.

<!-- TODO:
  Again, let's make sure we link to relevant locations documentation here.
-->

