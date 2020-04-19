# Overview

Solidus can manage your store's inventory. This allows you to keep track of your
current stock, [backorder][backorder] stock, as well as sold and shipped
inventory. Because inventory touches orders, shipments, and the contents of your
physical warehouse, there are many essential moving parts:

- `Spree::InventoryUnit`: Represents a stock item that has been sold. For more
  information, see [Inventory units](#inventory-units).
- `Spree::StockItem`: Counts the inventory for a specific `Spree::Variant` at a
  specific `Spree::StockLocation`. For more information, see [Stock
  items](#stock-items).
- `Spree::StockLocation`: Represents a location where stock items are shipped
  from. Each stock location has `Spree::StockItem`s for each variant in the
  store.
- `Spree::StockMovement`: Represents stock being moved from one
  `Spree::StockLocation` to another, or being  added or removed from your
  store's inventory. For more information, see [Stock
  movements](#stock-movements).
- `Spree::ReturnItem`: Represents an inventory unit that is returned by a
  customer.  For more information, see [Return items](#return-items).

[backorder]: https://www.investopedia.com/terms/b/backorder.asp

## Turn off inventory tracking

If your store does not require inventory tracking, you can turn off the
inventory system using Spree's application-wide configuration.

In your application's `/config/initializers/spree.rb` file, you can add your
`track_inventory_levels` configuration to the main `Spree::Config` block:

```ruby
# /config/initializers/spree.rb
Spree.config do |config|
  config.track_inventory_levels = false
end
```

## Inventory units

A `Spree::InventoryUnit` object is created every time that an item is sold. It
tracks the state of the sold item. The state could be `on_hand`, `backordered`,
`shipped`, or `returned`.

Inventory units associate each sold item with many other Solidus models. This
includes the specific variant that was sold, an order, a line item, and a
shipment.

<!--For more information, see the [Inventory units][inventory-units] article.-->

[inventory-units]: inventory-units.html

## Stock management

Before a `Spree::InventoryUnit` is created, your store's stock is tracked using
a number of stock management models. The following sections summarize the
models and their functions in the stock management system.

### Stock items

On-hand inventory is tracked using the `Spree::StockItem` model. Each
`Spree::Variant` in a store has a corresponding `Spree::StockItem` object with a
`count_on_hand` value that represents the number of items you have in stock.

Note that if you have two [stock locations](#stock-locations), there are two
`Spree::StockItem`s for each variant in your store: one for each
`Spree::StockLocation`. Each stock item counts the number of items in stock at a
specific stock location.

<!--For more information, see the [Stock items][stock-items] article.-->

[stock-items]: stock-items.html

### Stock movements

Whenever stock items are sold to customers, added to inventory, or removed from
inventory, a new `Spree::StockMovement` object is created. The stock movement
object documents how many items were added or removed.

Each `Spree::StockMovement` corresponds with a `Spree::StockItem` and how much
the item's `count_on_hand` increases or decreases.

<!--For more information, see the [Stock movements][stock-movements] article.-->

[stock-movements]: stock-movements.html

### Stock locations

A `Spree::StockLocation` represents a location where your inventory is shipped
from. Each stock location has many `Spree::StockItem`s and
`Spree::StockMovement`s.

Once a new stock location has been created, a new set of
[`Spree::StockItem`s](#stock-items) are created for it. The new set represents
every `Spree::Variant` in your store.

#### Stock transfers

If you manage multiple stock locations and inventory frequently moves between
them, you may benefit from the
[`solidus_stock_transfers`][solidus-stock-transfers] extension. This extension
adds a user interface for managing transfers in the `solidus_backend`.

[solidus-stock-transfers]: https://github.com/solidusio-contrib/solidus_stock_transfers

### Return items

<!-- TODO:
  For now, there is not dedicated article about return items.
-->

A `Spree::ReturnItem` is created for each inventory unit that a store
administrator has included in a [return authorization][return-authorizations].
Once a return item is received back from the customer, it can be re-added to
your on hand inventory.

Note that not all return items are resellable, as customer returns can be made
for many reasons.

For more information, see the [Returns][returns]
documentation.

[return-authorizations]: ../returns/return-authorizations.html
[returns]: ../returns/overview.html
