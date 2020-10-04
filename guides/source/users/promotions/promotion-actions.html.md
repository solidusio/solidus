# Promotion actions

Promotion actions define what should happen when a [promotion][promotions] is
applied to a customer's order. For example, a typical promotion action might be
free shipping or a fixed percentage-based discount.

Promotion actions create [adjustments][adjustments] on orders, line items, or
shipping charges.

[adjustments]: ../adjustments/overview.html
[promotions]: overview.html

## Create a promotion action

When you create a new promotion action for a promotion, you must go through the
following steps:

1. [Create a new promotion][create-a-new-promotion] or edit an existing
   promotion.
2. Choose a [promotion action type](#available-promotion-action-types) from the
   **Add action of type** drop-down menu.
3. Choose from the available [promotion calculators][promotion-calculators] in
   the **Calculated By** drop-down menu.
4. Set the discount amount for the current promotion action. This could be one
   of many types of discount depending on the promotion calculator being used.
   (For example, the amount could be a flat percentage or a flexible rate.)

Note that if you choose the promotion action type **Free Shipping** that steps
3. and 4. are not applicable.

[create-a-new-promotion]: overview.html#create-a-new-promotion
[promotion-calculators]: promotion-calculators.html

## Available promotion action types

When you add or edit a promotion, you can create promotion actions of four
types:

- **Create whole-order adjustment**: Promotion actions with this type apply to
  all of the items in an order.
- **Create per-line-item adjustment**: Promotion actions with this type apply to
  a single item in an order.
- **Create per-quantity adjustment**: Promotion actions with this type apply to
  items based on the quantity that is being purchased.
- **Free shipping**: Promotion actions with this type negate all shipping
  charges.

You can have multiple promotion actions with different promotion action types on
a single promotion.
