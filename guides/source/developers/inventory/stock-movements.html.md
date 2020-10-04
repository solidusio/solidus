# Stock movements

A `Spree::StockMovement` object is created every time that a stock item moves in
or out of a stock location. This objects documents how many items were added or
removed.

The `Spree::StockMovement` model has the following attributes:

- `stock_item_id`: The ID of the `Spree::StockItem` the movement is related to.
- `quantity`: The amount of stock items added or removed from the
  `Spree::StockItem`'s `count_on_hand` value.
- `originator_type` and `originator_id`: The model and ID of an object that
  initiated the creation of the current stock movement. For example, an
  originator could be an administrator (a `Spree::User`) adding new stock or a
  `Spree::Shipment` being created after an order is placed. 

<!-- TODO:
  There is an additional attribute: `action`. It seems to always be `nil`.
  Looking at some legacy code, it used to equal either `sold` or `received`,
  describing what kind of movement was taking place. Now, `action` does nothing
  out of the box, but it could be repurposed by a store's shipping/fulfillment
  departments. 
-->

## Usage example
 
A typical example of a stock movement would be when a customer buys an item from
your store:

1. A stock item has a `count_on_hand` value of `20`.
2. A customer buys one unit of its associated variant.
3. A new `Spree::StockMovement` object is created.
   - It has a `quantity` of `-1`.
   - It has a `originator_type` of `Spree::Shipment` because a new shipment
     triggered the movement.
4. The stock item's `count_on_hand` value is updated to `19`. 

## Administrating inventory

Administrators can generate stock movements by changing the "Count On Hand"
value for a stock item in the `solidus_backend` (on the **Stock** page).
However, they cannot create a stock movement directly.

Because of this, Solidus has no concept of *adding to* existing inventory. For
example:

- A stock item has a `count_on_hand` value of `7`.
- A store administrator receives 25 new items to add to inventory.
- They log into the backend and change the count on hand from `7` to `33`.
- This creates a new `Spree::StockMovement` with a quantity of `25`. (`7 + 25 =
  33`.)

If an administrator does not account for the units already in stock, they may
enter the wrong value into the "Count On Hand" field for an item.

For example, if the administrator changes the value from `7` to `25`, then the
stock movement only documents that `18` units were added to inventory. (`7 + 18
= 25`.) 
