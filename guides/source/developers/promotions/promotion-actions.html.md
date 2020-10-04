# Promotion actions

The `Spree::PromotionAction` model defines an action that should occur if the
promotion is activated and eligible to be applied. There can be multiple
promotion actions on a promotion.

Typically, a promotion action could be free shipping or a fixed percentage
discount.

A promotion action calculates the discount amount and creates a
`Spree::Adjustment` for the promotion. The adjustment then adjusts the price of
an order, line item, or shipment.

Promotion actions have a configurable base calculator (except for
`Spree::Promotion::Actions::FreeShipping`). This gives you and store
administrators flexibility for choosing how a promotion amount is calculated.

<!-- TODO:
  Once calculator documentation exists, link to it in the above paragraph so
  there's more context for anyone wondering what a "base calculator" is in
  Solidus.

  Similarly, we should link to the adjustments documentation once it's merged.
-->

## Available promotion action types

The following classes are [subclasses of the `Spree::Promotion::Actions`
model][promotion-actions]:

- `CreateAdjustment`: Creates a single adjustment associated to the current
  `Spree::Order`.
- `CreateItemAdjustments`: Creates an adjustment for each applicable
  `Spree::LineItem` in the current order.
- `CreateQuantityAdjustments`: Creates per-quantity adjustments. For example,
  you could create an action that gives customers a discount on each group of
  three t-shirts that they order at once.
- `FreeShipping`: Creates an adjustment that negates all shipping charges.

We recommend using `CreateItemAdjustments`s over `CreateAdjustment`. Over-level
adjustments can make calculating accurate refunds and some regions' taxes more
difficult for administrators.

[promotion-actions]: https://github.com/solidusio/solidus/tree/master/core/app/models/spree/promotion/actions

## Eligibility

Note that whenever an order, line item, or shipment with a promotion adjustment
on it is updated, the [eligibility][eligibility] of the promotion is re-checked
and the promotion actions are re-applied.

[eligibility]: overview.html#eligibility

## Register a custom promotion action

You can create a new promotion action for Solidus by creating a new class that
inherits from `Spree::PromotionAction`:

```ruby
# app/models/spree/promotion/actions/my_promotion_action.rb
module Spree
  class Promotion
    module Actions
      class MyPromotionAction < Spree::PromotionAction
        def perform(options={})
          ...
        end

        def remove_from(order)
          ...
        end
```

Your promotion action must implement the `perform(options = {})` method. This
method should return a boolean that declares whether the action was applied
successfully. We also recommend that you define a `remove_from(order)` method.
See the
[`Spree::Promotion::Actions::CreateItemAdjustments`][create-item-adjustments]
class for an example of these method definitions.

You must then register the custom action in an initializer in your
`config/initializers/` directory:

```ruby
Rails.application.config.spree.promotions.actions << MyNamespace::MyPromotionAction
```

[create-item-adjustments]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion/actions/create_item_adjustments.rb
