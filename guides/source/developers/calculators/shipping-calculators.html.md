# Shipping calculators

Solidus comes with a set of default calculators that account for typical
shipping scenarios:

- [Flat percent](#flat-percent)
- [Flat rate](#flat-rate) (per order)
- [Flat rate per package item](#flat-rate-per-package-item)
- [Flexi rate](#flexi-rate)
- [Price sack](#price-sack)

All of Solidus's shipping calculators inherit from the
`Spree::ShippingCalculator` class.

If the built-in calculators are not suitable for your store, you can create
custom shipping calculators. For more information, see the [Custom shipping
calculators][custom-shipping-calculators] article.

The rest of this article summarizes the functionality of Solidus's built-in
shipping calculators. Note that the code examples use [preferred
methods][preferred-methods] to set preference values. You can use these methods
to update any preference. For example:

```ruby
Spree::Calculator.find(1).update(preferred_currency: "EUR")
```

[custom-shipping-calculators]: ../shipments/custom-shipping-calculators.html
[preferred-methods]: overview.html#preferred-methods

## Flat percent

The [`Spree::Calculator::Shipping::FlatPercentItemTotal`
calculator][flat-percent] has one preference, `flat_percent`, that takes an
integer.

For each package that is shipped, this calculator takes the package's total and
charges a percentage of it. For example:

- An order has one shipment that includes three items.
- The total of the three items is $190.
- The calculator's `flat_percent` value is set to `10`.
- The shipping is calculated as 10% of $190: `$190 * (10 / 100)`.

## Flat rate

The [`Spree::Calculator::Shipping::FlatRate` calculator][flat-rate-per-order]
can be used to provide a flat rate discount. It has the following preferences:

- `amount`: The amount per item to calculate.
- `currency`: The currency. This value must match an available shipping method.
  The default value is your store's default currency setting.

The currency for this calculator is used to check to see if a shipping method is
available for an order. If an order's currency does not match a shipping
method's currency, then that shipping method is not displayed on the frontend.

## Flexi rate

The [`Spree::Calculator::Shipping::FlexiRate` calculator][flexi-rate] provides a
flexible rate depending on the items in a package. (Or, a subset of specific
items in a package.) It has the following preferences:

- `first_item`: The shipping price for the first item(s).
- `additional_item`: The shipping price for subsequent items.
- `max_items`: The maximum number of items that the rate applies to.
- `currency`: The currency. This value must match an available shipping method.
  The default value is your store's default currency setting.

## Flat rate per package item

The [`Spree::Calculator::Shipping::PerItem` calculator][flat-rate-per-item]
computes a value for every item on an order. This is useful for providing a
discount for a specific product without affecting other products. It has the
following preferences:

- `amount`: The amount per item to calculate.
- `currency`: The currency. This value must match an available shipping method.
  The default value is your store's default currency setting.

## Price sack

The [`Spree::Calculator::Shipping::PriceSack` calculator][price-sack] is useful
for when you want to provide a discount for an order which is over a certain
price. The calculator has the following preferences:

- `minimal_amount`: The minimum amount for the line items total to trigger the
  calculator.
- `normal_amount`: The amount to discount from the order if the line items total
  is less than the `minimal_amount`.
- `discount_amount`: The amount to discount from the order if the line items
  total is equal to or greater than the `minimal_amount`.
- `currency`: The currency. This value must match an available shipping method.
  The default value is your store's default currency setting.

[flat-percent]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_percent_item_total.rb
[flat-rate-per-order]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_rate.rb
[flat-rate-per-package-item]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/per_item.rb
[flexi-rate]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flexi_rate.rb
[price-sack]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/price_sack.rb

