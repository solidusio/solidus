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
from the Solidus admin (**Settings -> Locations -> Countries**) or from your
Rails console:

```
Spree::Country.create!(iso_name:"NEW COUNTRY", name:"New Country", states_required: true)
```

## States

A state is any sub-region of a country, whether that is a province, district, or
territory. If the state you require is not recognized, you can add it directly
from the Solidus Admin (**Settings -> Locations -> States**) or from your Rails
console:

```
Spree::State.create!(name: "New State", country_id: 1)
```

The `country_id` should match the country that the state belongs to.
