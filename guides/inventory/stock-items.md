# Stock items

On-hand inventory is tracked using the `Spree::StockItem` model. Each
`Spree::Variant` in a store has a corresponding `Spree::StockItem` object with a
`count_on_hand` value that represents the number of items you have in stock.

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

When administrators create a new product using the `solidus_backend`, they can
set an initial inventory "Count On Hand" value for the new product.

The `count_on_hand` value changes whenever a [stock movement][stock-movements]
occurs.  For example, if one unit of a product is sold the `count_on_hand` would
decrease by one.

### Changing the count on hand value

While a `Spree::StockMovement` object logs the increase or decrease of the
`count_on_hand` value, administrators can also edit the count on hand from the
`solidus_backend`.

Whenever an administrator updates the count on hand, they are discarding the old
value completely. So, if a stock item is
[backorderable](#backorderable-stock-items) and its `count_on_hand` is `-5`,
when the administrator changes the value to `20`, they are creating a
`Spree::StockMovement` with a value of `25`.

See the [Stock movements][stock-movements] article for more information.

[stock-movements]: stock-movements.md

## Backorderable stock items

If a `Spree::StockItem` is `backorderable`, then customers can continue to order
it after the product is sold out. When a sold out product continues to sell, the
`count_on_hand` would become a negative integer.
