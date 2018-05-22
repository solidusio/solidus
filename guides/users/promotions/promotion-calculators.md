# Promotion calculators

When you create a promotion action, one step is to select the promotion
calculator that it should use. You can do this by selecting a value in the
**Calculated By** drop-down menu.

Depending on the [type of promotion action][promotion-action-types] that you are
creating, only a subset of the promotion calculators may be available to use.

This table outlines the outlines the available promotions calculators and which
promotion action types they can be applied to:

| Calculator              | Orders           | Line items           | Line items (with quantity)       | Free shipping |
| ----------------------- | ---------------- | -------------------- | -------------------------------- | ------------- |
| [Distributed Amount][1] |                  | Available            |                                  |               |
| [Free Shipping     ][2] |                  |                      |                                  | Available     |
| [Flat Percent      ][3] | Available        |                      |                                  |               |
| [Flat Rate         ][4] | Available        | Available            | Available                        |               |
| [Flexible Rate     ][5] | Available        | Available            | Available                        |               |
| [Tiered Flat Rate  ][6] | Available        |                      |                                  |               |
| [Tiered Percent    ][7] | Available        | Available            |                                  |               |
| [Percent Per Item  ][8] |                  | Available            |                                  |               |

The following sections outline all of the promotion calculators, the contexts
they can be used in, and how they work. 

[1]: #distributed-amount 
[2]: #free-shipping
[3]: #flat-percent
[4]: #flat-rate
[5]: #flexible-rate
[6]: #tiered-flat-rate
[7]: #tiered-percent
[8]: #percent-per-item

## Flat rate

The **Flat Rate** calculator takes the total of an applicable order or line item
and discounts a fixed amount from it.

### Flexible rate

The **Flexible Rate** calculator provides a flexible rate depending on the
number of items on an order.

For example, you could sell one t-shirt for $20. But, if the customer buys five
t-shirts, the four additional t-shirt only costs $15.

It has the following preferences:

- **First Item**: The discount rate of the first item(s).
- **Additional Item**: The discount rate of subsequent items.
- **Max Items**: The maximum number of items this discount applies to.
- **Currency**: The currency. The default value is your store's default currency
  setting.

To replicate the example above, you could set the **First Item** amount to
`0.0`, the **Additional Item** to `5.0`, and the **Max Item** to `5`.

### Tiered percent

The **Tiered Percent** calculator provides a tiered percent discount. This
allows you to charge a percentage-based discount that depends on the order total
(or applicable line items).

For example, you could set a base discount of 10%, then give a greater discount
on orders over $100 and $200:

|   | Tier             | Discount (%) |
|---|------------------|--------------|
| 0 | Base             | 10%          |
| 1 | Orders over $100 | 15%          |
| 2 | Orders over $200 | 20%          |

This calculator has the following preferences:

- **Base Percent**: The base discount for any order where the promotion applies.
- **Currency**: The currency. The default value is your store's default currency
  setting.
- **Tiers**: You can add tiers using the **Add** button. Each tier takes an
  **Amount ($)** of money that triggers the next tier, as well as a **Percentage
  (%)** that sets how much of a discount the next tier should be. 







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

[distributed-amount]:
https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/distributed_amount.rb
[percent-on-line-item]:
https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/percent_on_line_item.rb

## Free shipping promotions

You can create promotions that negate all shipping charges on an order. This
type of promotion does not require a specific calculator. Instead, it uses the
[`Spree::Promotion::Action::FreeShipping` promotion
action][free-shipping-promotion-action] directly.

[free-shipping-promotion-action]:
https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion/actions/free_shipping.rb
` } }`
