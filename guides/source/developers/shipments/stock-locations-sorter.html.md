# Stock locations sorter

This article explains the purpose, interface and correct usage of a custom stock locations sorter.

Your app's stock locations sorter defines the order in which stock locations are used to allocate
inventory when creating packages for an order. The sorter is called by `Spree::Stock::SimpleCoordinator`
when allocating inventory for an order.

## Pre-configured sorters

Currently, we only provide two sorters, which you should use unless you need custom logic:

- [Unsorted](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/location_sorter/unsorted.rb),
  which allocates inventory from stock locations as they are returned from the DB.
- [Default first](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/location_sorter/default_first.rb),
  which allocates inventory from the default stock location first.

## Custom sorter API

A custom sorter should inherit from `Spree::Stock::LocationSorter::Base` and implement a `sort` method
which accepts a `Spree::StockLocation::ActiveRecord_Relation` and returns an enumerable of stock
locations. Note that the return value does not have to be an AR relation.

Here's an example that sorts stock locations by a custom `priority` attribute:

```ruby
class Spree::Stock::LocationSorter::Priority < Spree::Stock::LocationSorter::Base
  def sort
    stock_locations.order(priority: :asc)
  end
end
```

### Switching the sorter

Once you have created the logic for the new sorter, you need to register it so that it's used by
`Spree::Stock::SimpleCoordinator`.

For example, you can register it in your `/config/initializers/spree.rb` initializer:

```ruby
# /config/initializer/spree.rb
Spree.config do |config|
  # ...
  config.stock.location_sorter_class = 'Spree::Stock::LocationSorter::Priority'
  # ...
end
```
