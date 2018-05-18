# Promotion rules

The `Spree::PromotionRule` model sets a rule that determines whether a promotion
is eligible to be applied. Promotions may have no rules or many different rules.

An example of a typical promotion rule would be a minimum order total of $75
USD or that a specific product is in the cart at checkout.

Many conventional types of promotion rules are included by default. Multiple
promotion rules can exist on each promotion, although no rules are required.

# Available promotion rule types

The following classes are [subclasses of the `Spree::Promotion::Rules`
model][promotion-rules]:

- `FirstOrder`: Eligible for a customer's first order only.
- `FirstRepeatPurchaseSince`: Eligible for a customer's first repeat purchase
  since a specified date.
- `NthOrder`: Eligible for a customer's *n*th order only.
- `ItemTotal`: Eligible if the order total (before any adjustments) is less than
  or greater than a specified amount.
- `OneUsePerUser`: Eligible for use one time for each user.
- `Product`: Eligible for specified products only.
- `OptionValue`: Eligible for specified variants (product option values) only.
- `Taxon`: Eligible for products with specified taxons.
- `User`: Eligible for specified users.
- `UserRole`: Eligible for users with the specified user role.
- `UserLoggedIn`: Eligible for users who are logged in.

<!-- TODO:
  It may be useful to link to option values documentation and taxons
  documentation here, unless we explain what they are further in-line.
  Once that documentation is merged, we can add those link.
-->

[promotion-rules]: https://github.com/solidusio/solidus/tree/master/core/app/models/spree/promotion/rules

## Eligibility

Note that whenever an order, line item, or shipment with a promotion adjustment
on it is updated, the [eligibility][eligibility] of the promotion is re-checked,
and the adjustment is recalculated if necessary.

[eligibility]: overview.html#eligibility

## Rules match policy

By default, `Spree::Promotion`s have a `match_policy` value of `all`, meaning
that all of the promotion rules on a promotion must be met before the promotion
is eligible. However, this can be changed to `any`.

Administrators can change the match policy when adding or editing a promotion.
By default, promotions use the "Match all of these rules" setting, but they can
be changed to use "Match any of these rules".

## Register a custom promotion rule

You can create a custom promotion rule by creating a new class that inherits
from `Spree::PromotionRule`:

```ruby
# app/models/spree/promotion/rules/my_promotion_rule.rb
module Spree
  class Promotion
    module Rules
      class MyPromotionRule < Spree::PromotionRule
        def applicable?(promotable)
          promotable.is_a?(Spree::Order)
        end

        def eligible?(order, options = {})
          ...
        end

        def actionable?(line_item)
          ...
        end
      ...
```

Note that the `applicable?` and `eligible?` are required:

- `eligible?` should return `true` or `false` to indicate if the promotion is
  eligible for an order.
- If your promotion supports discounts for some line items but not others,
  define `actionable?` to return `true` when the specified line item meets the
  criteria for the promotion. It should return `true` or `false` to indicate if
  this line item can have a line item adjustment carried out on it.

For example, if you are giving a promotion on specific products only,
`eligible?` should return true if the order contains one of the products
eligible for promotion, and `actionable?` should return true when the line item
specified is one of the specific products for this promotion.

Note that you can retrieve the associated `Spree::Promotion` information by
calling the `promotion` method.

You must then register the custom rule in an initializer in your
`config/initializers/` directory:

```ruby
Rails.application.config.spree.promotions.rules << Spree::Promotion::Rules::MyPromotionRule
```

<!-- TODO:
  The Spree documentation has a section about getting your custom promotion
  rule to show up in the backend for administrators. It might be worth it to
  append a similar section here or in another more how-to oriented article.
-->

