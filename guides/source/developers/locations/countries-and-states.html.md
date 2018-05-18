# Countries and states

Solidus uses the list of countries and states provided by [Carmen][carmen-repo],
which uses the countries and states available in the [Debian `iso-codes`
package][debian-iso-codes]. Solidus creates new `Spree::Country` and
`Spree::State` objects for each country and state.

Carmen is generally up-to-date and should provide Solidus with any country or
state you would ever need.

[carmen-repo]: https://github.com/carmen-ruby/carmen
[debian-iso-codes]: https://packages.debian.org/sid/all/iso-codes

## Countries

If a country or state you require is not recognized, you can add it directly
from your Rails console:

```ruby
Spree::Country.create!(iso_name:"NEW COUNTRY", name:"New Country", states_required: true)
```

Some countries do not need to be divided into states or subregions. For those
countries, the `Spree::Country` object's `states_required` field is set to
`false`. You may wish to change this value for your custom country or any other
country that you ship to.

## States

A state is any sub-region of a country, whether that is a province, district, or
territory. If the state you require is not recognized, you can add it directly
from your Rails console:

```ruby
Spree::State.create!(name: "New State", country_id: 1)
```

The `country_id` should match the country that the state belongs to.
