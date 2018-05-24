# Promotion calculators

Promotion calculators are similar to [shipping
calculators][shipping-calculators]: they calculate against your preferred
amounts, percentages, and currencies. The main difference is that promotions
adjust prices as discounts rather than charges.

Solidus includes a number of built-in promotion calculators. Because promotions
can adjust orders, line items, or shipping charges, note that some of the
built-in calculators can only be used on a subset of promotions.

The rest of this article summarizes the available promotion calculators, grouped
by the types of promotions they can calculate (either order, line item, or
shipment promotions).

[shipping-calculators]: shipping-calculators.html

## Order or line item promotions

The following calculators are available to use on whole-order or line item
promotions:

- [Flat rate](#flat-rate)
- [Flexi rate](#flexi-rate)
- [Tiered percent](#tiered-percent)

### Flat rate

The [`Spree::Calculator::FlatRate` calculator][flat-rate] has the following
preferences:

- `amount`: The amount per item to calculate.
- `currency`: The currency. The default value is your store's default currency
  setting.

This calculator takes the total of an applicable order or line item and
discounts a fixed amount from it.

### Flexi rate

The [`Spree::Calculator::FlexiRate` calculator][flexi-rate] provides a flexible
rate depending on the number of items on an order.

For example, you could sell one t-shirt for $20. But, if the customer buys five
t-shirts, the four additional t-shirt only costs $15.

It has the following preferences:

- `first_item`: The discount rate of the first item(s).
- `additional_item`: The discount rate of subsequent items.
- `max_items`: The maximum number of items this discount applies to.
- `currency`: The currency. The default value is your store's default currency
  setting.

To replicate the example above, you could set the `first_item` to `0.0`, the
`additional_item` to `5.0`, and the `max_items` to `5`.

### Tiered percent

The [`Spree::Calculator::TieredPercent` calculator][tiered-percent] provides a
tiered percent discount. This allows you to charge a percentage-based discount
that depends on the order total (or applicable line items).

For example, you could set a base discount of 10%, then give a greater discount
on orders over $100 and $200:

|   | Tier             | Discount (%) |
|---|------------------|--------------|
| 0 | Base             | 10%          |
| 1 | Orders over $100 | 15%          |
| 2 | Orders over $200 | 20%          |

This calculator has the following preferences:

- `base_percent`: The base discount for any order where the promotion applies.
- `tiers`: A hash where the key is the minimum order total for the tier and the
  value is the tier discount. Using the example from the table above, the hash
  could read: `{ $100=>15%, $200=>20% }`.
- `currency`: The currency. The default value is your store's default currency
  setting.

[flat-rate]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/flat_rate.rb
[flexi-rate]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/flexi_rate.rb
[tiered-percent]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/tiered_percent.rb

## Order promotions only

The following calculators are available to use with order promotions only:

- [Tiered flat rate](#tiered-flat-rate)
- [Flat percent (item total)](#flat-percent-item-total)

### Tiered flat rate

The [`Spree::Calculator::TieredFlatRate` calculator][tiered-flat-rate] provides
a tiered flat rate discount. This allows you to charge a rate-based discount
that depends on the order total. For example, you could set a base discount of
$10, then give a greater discount on orders over $100, $200, and $500:

|   | Tier             | Discount ($) |
|---|------------------|--------------|
| 0 | Base             | $10          |
| 1 | Orders over $100 | $15          |
| 2 | Orders over $200 | $20          |
| 3 | Orders over $500 | $25          |

This calculator has the following preferences:

- `base_amount`: The base discount for any order where the promotion applies.
- `tiers`: A hash where the key is the minimum order total for the tier and the
  value is the tier discount: `{ tier=>discount_amount }`.
- `currency`: The currency. The default value is your store's default currency
  setting.

### Flat percent (item total)

The [`Spree::Calculator::FlatPercentItemTotal`][flat-percent-item-total]
calculator provides a flat, percentage-based discount on an order. In the
`solidus_backend` interface administrators can use this calculator by choosing
the whole-order calculator labeled "Flat Percent". It has the following
preference:

- `flat_percent`: The percentage that the order should be discounted.

[tiered-flat-rate]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/tiered_flat_rate.rb
[flat-percent-item-total]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/flat_percent_item_total.rb

## Line item promotions only

The following calculators are available to use with line item promotions only:

- [Distributed amount](#distributed-amount)
- [Percent on line item](#percent-on-line-item)

### Distributed amount

The [`Spree::Calculator::DistributedAmount` calculator][distributed-amount]
provides an amount-based discount on all of the applicable line items in an
order. The discount amount is distributed across all of the line items.

For example, if your promotion offers a $5 discount and a customer orders a $20
item as well as a $10 item, then the discount is distributed across both items:
$3.33 (on the $20 item) and $1.67 (on the $10 item).

This calculator has the following preferences:

- `amount`: The discount amount given if the line items should be discounted.
- `currency`: The currency. The default value is your store's default currency
  setting.

### Percent on line item

The [`Spree::Calculator::PercentOnLineItem` calculator][percent-on-line-item]
provides a percentage-based discount for each applicable line item in an order.
In the `solidus_backend` interface, this calculator is labeled "Percent Per
Item". It has the following preference:

- `percent`: The percentage discount that should be given to each applicable
  line item.

[distributed-amount]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/distributed_amount.rb
[percent-on-line-item]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/percent_on_line_item.rb

## Free shipping promotions

You can create promotions that negate all shipping charges on an order. This
type of promotion does not require a specific calculator. Instead, it uses the
[`Spree::Promotion::Action::FreeShipping` promotion
action][free-shipping-promotion-action] directly.

[free-shipping-promotion-action]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion/actions/free_shipping.rb
