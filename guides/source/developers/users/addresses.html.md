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

- `name`: The full name for the person at this address.
- `firstname`: *Deprecated: will be removed in Solidus 3.0, please use `name` attribute* - The first name for the person at this address.
- `lastname`: *Deprecated: will be removed in Solidus 3.0, please use `name` attribute* - The last name for the person at this address.
- `address1` and `address2`: The street address (with an optional second line).
- `city`: The city where the address is.
- `zipcode`: The postal code.
- `phone` and `alternative_phone`: The customer's phone number(s).
- `state_name`: If the customer uses a region name that doesn't correspond with
  a country's list of states, the address can store the user-entered
  `state_name` as a fallback.
- `alternative_phone`: The alternative phone number.
- `company`: A company name.
- `state_id` and `country_id`: IDs for the `Spree::State` and `Spree::Country`
  objects associated with the customer's entered address. These are used to
  determine the customer's [zone][zones], which determines applicable taxation
  and shipping methods.

For more information about how countries, states, and zones work in Solidus, see
the [Locations][locations] documentation.

[locations]: ../locations/overview.html
[solidus-auth-devise]: https://github.com/solidusio/solidus_auth_devise
[zones]: ../locations/zones.html

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

## Required address values

By default, `Spree::Address` objects require many address values, including a
phone number and zip code value.

You may want to alter Solidus's address requirements for your store. For
example, if you do not require customer phone numbers in order for them to check
out.

Right now, you need to [monkey-patch][monkey-patch] the `Spree::Address` model
in order to change its requirements. For example, you could prepend your custom
behavior that redefines `Spree::Address`'s `require_phone?` method: 

```ruby
module PhoneNotRequired
  def require_phone?
    false
  end
end

Spree::Address.prepend(PhoneNotRequired)
```

Similarly, if you ship to countries that don't require postal codes, like Hong
Kong or Macau, you may want to make postal codes optional instead of required.

Right now, you can monkey-patch the `Spree::Address` model in order to remove or
change the requirements. For example, you could prepend your own custom behavior
that redefines `Spree::Address`'s `require_zipcode?` method:

```ruby
module ZipCodeValidation
  def require_zipcode?
    # if a country that you ship to does not require postal codes, add its iso
    # code to the following array so that Spree::Address does not require zip
    # codes for addresses in those countries.
    !['HK','MO'].include?(country.iso)
  end
end

Spree::Address.prepend(ZipCodeValidation)
```

<!-- TODO:
  Ideally, we do not want to recommend monkey-patching the Spree::Address model.
  It would be great make address requirements more configurable in general.
  Then, we can revisit this documentation.
-->

[monkey-patch]: https://en.wikipedia.org/wiki/Monkey_patch
