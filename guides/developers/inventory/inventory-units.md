# Inventory units

<!-- TODO:
  This article is a stub.
-->

A `Spree::InventoryUnit` object is created every time that an item is sold.
It tracks a sold item as it changes location: from being a sold item waiting in the
warehouse to be shipped, to being a shipped item (or potentially a returned item).

Note that the `Spree::InventoryUnit` tracks an item as an object associated with
a `Spree::Order`, a `Spree::Shipment` and a specific `Spree::LineItem`. This
allows you to more closely track the status of an order and the line items and
shipments associated with it.

A `Spree::InventoryUnit` object has the following attributes:

- `state`: The current state of the inventory unit. The state value can be
  `on_hand`, `backordered`, `shipped`, or `returned`.
- `variant_id`: The ID for the `Spree::Variant` corresponding with the inventory
  unit that has been sold.
- `shipment_id`: The ID for the `Spree::Shipment` that the inventory unit is
  being shipped in.
- `pending`: Documents whether the current unit is pending or finalized. If
  `true`, the stock for this unit has not yet been allocated to a shipment. If
  `false`, the stock has been finalized and is no longer tracked in the
  `Spree::StockItem`'s `count_on_hand` value.
- `line_item_id`: The ID for the `Spree::LineItem` that the inventory unit
  corresponds with.
- `carton_id`: The ID for the `Spree::Carton` that the inventory unit belongs
  to.

<!-- TODO:
  The `pending` attribute may require a clearer description. Alternatively,
  there could be additional documentation somewhere that we link to here
  describing what "pending" and "finalized" mean in the larger scheme of
  things.
-->
