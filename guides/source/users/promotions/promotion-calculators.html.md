# Promotion calculators

When you create a promotion action, one step is to select the promotion
calculator that it should use. You can do this by selecting a value in the
**Calculated By** drop-down menu.

Calculators can calculate for one of four different *calculables*:

- Orders
- Line items
- Line items (with quantity)
- Free shipping

The term calculables sounds very technical. All that it means is "an object that
can be calculated". In this case, we can calculate the price of an order, an
item (or items) on an order, or an order's shipping charges.

When you are creating a new promotion, the calculable is set by the [type of
promotion action][promotion-action-types] that you choose.

This table outlines the promotions calculators and which calculables they are
available to calculate:

| Calculator              | Orders     | Line items  | Line items (with quantity)  | Free shipping |
| ----------------------- | ---------- | ----------- | --------------------------- | ------------- |
| [Distributed Amount][1] |            | Available   |                             |               |
| [Free Shipping][2]      |            |             |                             | Available     |
| [Flat Percent][3]       | Available  |             |                             |               |
| [Flat Rat][4]           | Available  | Available   | Available                   |               |
| [Flexible Rate][5]      | Available  | Available   | Available                   |               |
| [Tiered Flat Rate][6]   | Available  |             |                             |               |
| [Tiered Percent][7]     | Available  | Available   |                             |               |
| [Percent Per Item][8]   |            | Available   |                             |               |

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

[promotion-action-types]: overview.html#available-promotion-action-types

## Distributed amount

The **Distributed Amount** calculator provides an amount-based discount on all
of the applicable line items in an order. The discount amount is distributed
across all of the line items.

For example, if your promotion offers a $5 discount and a customer orders a $20
item as well as a $10 item, then the discount is distributed across both items:
$3.33 (on the $20 item) and $1.67 (on the $10 item).

Set the **Preferred amount** that should be distributed across all of the line
items as a discount.

## Free shipping

The free shipping calculator only requires that you use the promotion action
type **Free shipping** when you create the promotion action. Then, all shipping
charges from an order are deducted when the promotion is activated. 

## Flat percent

The **Flat Percent** calculator provides a flat, percentage-based discount on an
order.

## Flat rate

The **Flat Rate** calculator takes the total of an applicable order or line item
and discounts a fixed amount from it.

## Flexible rate

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

## Tiered flat rate

The **Tiered Flat Rate** calculator provides a tiered flat rate discount. This
allows you to charge a rate-based discount that depends on the order total. 

This calculator has the following settings:

- **Base Amount**: The base discount for any order where the promotion applies.
- **Currency**: The currency. The default value is your store's default currency
  setting.
- **Tiers**: Each tier adds a new discount level. New tiers can be added using
  the **Add** button.

### How tiers work

You can add additional tiers using the **Add** button. Each tier takes an **Tier
Amount ($)** of money that triggers the next tier. For each trigger that you
create, you also set a new **Discount Amount ($)**  that should be used as new
discount level for that tier.

For example, you could set a base discount of $10, then give a greater discount
on orders over $100, $200, and $500:

|   | Tier             | Discount ($) |
|---|------------------|--------------|
| 0 | Base             | $10          |
| 1 | Orders over $100 | $15          |
| 2 | Orders over $200 | $20          |
| 3 | Orders over $500 | $25          |

<!-- TODO:
  Add screenshot that shows the admin UI filled in with the above
  example information.
-->

### Tiered percent

The **Tiered Percent** calculator provides a tiered percent discount. This
allows you to charge a percentage-based discount that depends on the order total
(or applicable line items).

This calculator has the following settings:

- **Base Percent**: The base discount for any order where the promotion applies.
- **Currency**: The currency. The default value is your store's default currency
  setting.
- **Tiers**: Each tier adds a new discount level. New tiers can be added using
  the **Add** button.

### How tiers work

You can add additional tiers using the **Add** button. Each tier takes an **Tier
Amount ($)** of money that triggers the next tier. For each trigger that you
create, you also set a new **Discount Percentage (%)**  that should be used as
new discount level for that tier.

In the following example, there are tiers set up for the $100 and $100 purchase
mark:

|   | Tier             | Discount (%) |
|---|------------------|--------------|
| 0 | Base             | 10%          |
| 1 | Orders over $100 | 15%          |
| 2 | Orders over $200 | 20%          |

<!-- TODO:
  Add screenshot that shows the admin UI filled in with the above
  example information.
-->

## Percent per item 

The **Percent Per Item** calculator provides a percentage-based discount for
each applicable line item in an order. 

