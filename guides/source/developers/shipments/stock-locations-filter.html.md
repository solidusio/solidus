# Stock locations filter

Stock locations filter is an object responsible to select which stock locations are used when
[splitting shipments][split-shipments]. If a stock location is filtered out, its stock items
are not considered when creating shipments packages. By default, the filter returns only active
stock locations.

[split-shipments]: split-shipments.html

## Pre-configured filters

Solidus ships with just one filter:

- [Active](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/location_filter/active.rb),
    which returns only active stock locations.

It's very easy to create custom ones.

## Custom stock locations filter API

A custom filter should inherit from `Spree::Stock::LocationFilter::Base` and implement a `filter`
method which accepts a `Spree::StockLocation::ActiveRecord_Relation` and a `Spree::Order`, and
returns an enumerable of stock locations. Note that the return value does not have to be an AR relation.

For example, you could create a new Stock Location Filter that takes into account only active stock
locations from the same country of the order:

```ruby
class Spree::Stock::LocationFilter::SameOrderCountry < Spree::Stock::LocationFilter::Base
  def filter
    stock_locations.active.where(country: order.country)
  end
end
```

### Changing the default stock locations filter

Once you have created the logic for the new filter, you need to register it so that it's used in
the split shipments logic.

For example, you can register it in your `/config/initializers/spree.rb` initializer:

```ruby
# /config/initializer/spree.rb
Spree.config do |config|
  # ... 
  config.stock.location_filter_class = 'Spree::Stock::LocationFilter::SameOrderCountry'
  # ... 
end
```
