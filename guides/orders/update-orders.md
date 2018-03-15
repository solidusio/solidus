# Update orders 

You need to use the `recalculate` method on a `Spree::Order` to keep its total
up-to-date.  Note that the total changes every time that line items and
adjustments are added or modified. The `recalculate` method calls out to the
[`Spree::OrderUpdater` class][order-updater].

For example, the `solidus_backend` gem's
[`Spree::Admin::AdjustmentsController`][adjustments-controller] uses the
`recalculate` method to update totals throughout the lifetime of an order:

```ruby
def update_totals
  @order.reload.recalculate
end
```

The `update_totals` method is called every time that adjustments are created,
destroyed, and updated.

Whenever you change the code that touches the values of a `Spree::Order`, use
the `recalculate` method to ensure your order's totals are accurate. For
example, you would want to call the `recalculate` method in the following
scenarios:

- Whenever you create or modify a `Spree::Payment` that changes the order's
  `payment_state` value.
- Whenever a `Spree:LineItem` on the order has a price change.

[adjustments-controller]: https://github.com/solidusio/solidus/blob/master/backend/app/controllers/spree/admin/adjustments_controller.rb
[order-updater]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/order_updater.rb
