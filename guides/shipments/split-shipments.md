# Split shipments

Solidus supports split shipments out of the box. This feature addresses the
needs of complex Solidus stores who require detailed inventory management, and
sophisticated shipping and warehouse logic. It also allows you to manage
shipments from multiple stock locations.

[`Spree::Stock::SimpleCoordinator`][simple-coordinator] contains all of the
business logic for how stock should be packaged. If your store requires a
specialized flow for handling split shipments, the simple coordinator should
provide a good starting point for customizations. 

## Creating proposed shipments

An order's shipments are determined by
[`Spree::Stock::SimpleCoordinator`][simple-coordinator] while the 
`Spree::Order`'s' state is set to `delivery`. This occurs before the customer
has completed their order at checkout.

The simple coordinator deletes any existing shipments for an order and then
creates all of the shipments currently available for this order.

[simple-coordinator]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/simple_coordinator.rb

The simple coordinator performs a number of tasks in order to create shipment
proposals:

1. The coordinator calculates the availability of the ordered items.
2. Inventory is allocated from available stock to the current order.
3. It splits the order into logical packages based on stock locations and
   inventory at those locations.
4. Each package generates a new `Spree::Shipment` object that is associated with
   the current order.
5. It estimates the shipping rates for each shipment.
 
After the proposed shipments have been determined, the customer can continue the
checkout process and take the order from the `delivery` state to the `payment`
state.

## Splitters

In order to split shipments, Solidus runs a series of splitters in sequence. The
first splitter in the sequence takes the array of packages from the order,
splits the order into packages according to its rules, then passes the packages
on to the next splitter in the sequence.

### Default splitters

Solidus comes with thre built-in splitters:

- [Backordered splitter][backordered-splitter]: Splits an order based on the
  amount of inventory on hand at each stock location.
- [Shipping category splitter][shipping-category-splitter]: Splits an order into
  packages based on a product's shipping categories. This means that each
  package only has items that belongs to the same shipping category.
- [Weight splitter][weight-splitter]: Splits an order into packages based on a
  weight
  threshold. This means that each package has a maximum weight: if a new item
  is added to the order and it causes a package to go over the weight threshold,
  a new package is created. All packages need to weigh less than the threshold.
  You can set the weight threshold by changing
  the `Spree::Stock::Splitter::Weight.threshold` value in an initializer. (It
  defaults to `150`.)

[backordered-splitter]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/splitter/backordered.rb
[shipping-category-splitter]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/splitter/shipping_category.rb
[weight-splitter]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/stock/splitter/weight.rb

#### Custom splitters

Note that splitters can be customized. Create you own splitter by inheriting the
`Spree::Stock::Splitter::Base` class.

For an example of a simple splitter, take a look at Solidus's [weight
splitter][weight-splitter]. This splitter ensures that items that weigh
more than `150` are split into their own shipment.

After you create your splitter, you need to add it to the array of splitters
that Solidus uses. To do this, add the following to your
`config/initializers/spree.rb` file:

```ruby
Rails.application.config.spree.stock_splitters <<
Spree::Stock::Splitter::CustomSplitter
```

You can also override the splitters used in Solidus, rearrange them, or
otherwise customize them from the `config/initializers/spree.rb`:

```ruby
Rails.application.config.spree.stock_splitters = [
  Spree::Stock::Splitter::CustomSplitter,
  Spree::Stock::Splitter::ShippingCategory
]
```

If you want to add different splitters for each of your `Spree::StockLocation`s,
you can decorate the `Spree::Stock::Coordinator` class and override the
`splitters` method.

#### Turn off split shipments

If you don't want to split packages in any case, you can set the
`config.spree.stock_splitters` option to an empty array:

```ruby
Rails.application.config.spree.stock_splitters = []
```
