# Stock allocator

This article explains the concept of a stock allocator and its usage.

During the checkout process, after the delivery step, the order stocks the ordered stock items
to ship them.

The stock allocator defines the logic with which these packages are created.

The allocator is called by `Spree::Stock::SimpleCoordinator` when allocating inventory for an order.

## Pre-configured allocator

Currently, we only have one allocator, which you should use unless you need custom logic:

- [On-hand First](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/allocator/on_hand_first.rb),
  which allocates inventory using Solidus' pre-existing logic.

  Examples:
    - Someone orders a product which doesn't have stock items on hand, but is backorderable:
      - The order stocks the inventory and create one backordered shipment.
    - Someone orders a product which has on hand stock items and it's backorderable:
      - If the ordered quantity doesn't exceed the availability, the order stocks the inventory
        and creates one `on_hand` shipment.
      - Otherwise, if the order exceeds the availability, the order stocks the inventory
        and create two shipments, one `on_hand` up to the number of available stock items and one
        backordered for the rest.

## Custom allocator API

A custom allocator should inherit from `Spree::Stock::Allocator::Base` and implement an
`allocate_inventory` method which accepts a `Spree::StockQuantities` and returns the packages
splitted with the allocator's logic.

```ruby
class Spree::Stock::Allocator::CustomAllocator < Spree::Stock::Allocator::Base
  def allocate_inventory(desired)
    # Some code to allocate packages with different logic
  end
end
```

### Switching the allocator

Once you have created the logic for the new allocator, you need to register it so that it's used by
`Spree::Stock::SimpleCoordinator`.

For example, you can register it in your `/config/initializer/spree.rb` initializer:

```ruby
# /config/initializer/spree.rb
Spree.config do |config|
  # ...
  config.stock.allocator_class = 'Spree::Stock::Allocator::CustomAllocator'
  # ...
end
```
