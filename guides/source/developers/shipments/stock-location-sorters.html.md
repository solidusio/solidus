# Stock location sorters

This article explains the purpose, interface and correct usage of custom stock location sorters.

Your app's stock location sorter defines the order in which stock locations are used to allocate
inventory when creating packages for an order. The sorter is called by `Spree::Stock::SimpleCoordinator`
when allocating inventory for an order.

## Pre-configured sorters

Currently, we only have two sorters, which you should use unless you need custom logic:

- [Unsorted](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/sorter/unsorted.rb),
  which allocates inventory from stock locations as they are returned from the DB.
- [Default first](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/sorter/default_first.rb),
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

For example, you can register it in your `/config/application.rb` initializer:

```ruby
# /config/application.rb
module MyStore
  class Application < Rails::Application
    # ...

    initializer 'spree.register.stock_location_sorter' do |app|
      app.config.spree.stock.location_sorter_class = 'Spree::Stock::LocationSorter::Priority'
    end
  end
end
```
