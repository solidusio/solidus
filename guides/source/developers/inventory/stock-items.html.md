# Stock items

On-hand inventory is tracked using the `Spree::StockItem` model. A stock item
tracks stock at a single `Spree::StockLocation`.

If you only track stock at one stock location, then every `Spree::Variant` in
your store has one corresponding `Spree::StockItem` object. If you track stock
at two stock locations, then every `Spree::Variant` in your store has *two*
corresponding `Spree::StockItem`s: one for each `Spree::StockLocation`.

The `Spree::StockItem`'s `count_on_hand` value that represents the number of
items you have in stock.

`Spree::StockItem` objects have the following attributes:

- `stock_location_id`: The ID for the `Spree::StockLocation` where the stock
  item is located.
- `variant_id`: The ID for the `Spree::Variant` that this stock item represents.
- `count_on_hand`: The number of units currently in inventory. See [Count on
  hand](#count-on-hand) for more information.
- `backorderable`: Sets whether the stock item should be
  [backorderable](#backorderable-stock-items).
- `deleted_at`: A timestamp that logs when this stock item was deleted from
  inventory. Otherwise, the value is `nil`.

## Count on hand

Administrators can manage the "Count On Hand" value for every product they sell
on their store.

The `count_on_hand` value changes whenever a [stock movement][stock-movements]
occurs.  For example, if one unit of a product is sold the `count_on_hand` would
decrease by one.

### Changing the count on hand value

While a `Spree::StockMovement` object logs the increase or decrease of the
`count_on_hand` value, administrators can also edit the count on hand from the
`solidus_backend`.

Whenever an administrator updates the count on hand, they are discarding the old
value completely. So, if a stock item's `count_on_hand` is `5`, when the
administrator changes the value to `20`, they are creating a
`Spree::StockMovement` with a value of `15`.

See the [Stock movements][stock-movements] article for more information.

[stock-movements]: stock-movements.html

## Backorderable stock items

If a `Spree::StockItem` is `backorderable`, then customers can continue to order
it after the product is sold out. When a sold out product continues to sell, the
`count_on_hand` becomes a negative integer.

For example, if a customer orders five backorderable items and its
`count_on_hand` becomes `-5`, the customer can still check out successfully.
[Inventory units][inventory-units] with the `state` value of `backordered` are
created for the five items.

The `Spree::Shipment`(s) associated with the backordered items cannot be shipped
until the stock has been replenished. Once the item is in stock again, each
backordered inventory unit's `state` value is changed from `backordered` to
`on_hand` and the shipment becomes shippable.

[inventory-units]: inventory-units.html
