# Display total methods

The `Spree::Order` model includes a number of useful methods for displaying
totals and balances:

- `display_outstanding_balance`: The outstanding balance for the order, calculated by
  taking the `total` and subtracting the current `payment_total`.
- `display_item_total`: The total of the line items on the order. 
- `display_adjustment_total`: The total of the adjustments on the order.
- `display_total`: The order total.
- `display_total_available_store_credit`: The total available store credit.
- `display_order_total_after_store_credit`: The order total after store credit
  has been applied.
- `display_store_credit_remaining_after_capture`: The amount of store credit
  remaining after an order payment has been captured.

<!-- TODO:
  Write and link to documentation about store credit in the Payments
  documentation.
-->

By default, the following methods return `Spree::Money` objects configured with
the order's currency symbol. For example:

```ruby
@order.display_total.to_html 
# => "$10.99"
```

Because `Spree::Money` objects are based on the [Ruby Money
library][ruby-money], you can further change what information is displayed using
its [`format`][ruby-money-format] method:

```ruby
@order.display_total.format(with_currency: true)
# => "$10.99 USD"
```

[ruby-money]: https://github.com/RubyMoney/money
[ruby-money-format]: https://www.rubydoc.info/gems/money/Money:format

