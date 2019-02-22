# Overview

Solidus's promotions system allows you to give discounts to customers. Discounts
can be applied to different amounts that make up the order: 

- Discounts can apply to the entire order's cost.
- Discounts can apply to a line item (or a set of line items) on the order.
- Discounts can apply to the shipping charges on the order.

The promotions system provides a set of handlers, rules, and actions that work
together to provide flexible discounts in any scenario.

To account for all of the ways a discount may be applied, the promotions system
has many complex moving parts.

We recommend that you start up a Solidus store on your local machine and see the
built-in promotions functionality yourself, as store administrators have a
flexible promotions system available by default
([`http://localhost:3000/admin/promotions`][promotions-admin]). Here,
administrators can add promotions and create complex strings of promotion rules
and actions if necessary.

[promotions-admin]: http://localhost:3000/admin/promotions

## Promotion architecture

The following sections summarize the main parts of Solidus's promotions system.

<!-- TODO:
  Currently there is no documentation about `Spree::PromotionCode`s activating
  promotions using a URL.
-->

### Promotion model

The `Spree::Promotion` model defines essential information about a promotion.
This includes the promotion's name, description, and whether the promotion
should be active or not.

Take note of the following promotion attributes:

- `name`: The name for the promotion. This is displayed to customers as an
  adjustment label when it is applied.
- `description`: An administrative description for the promotion.
- `usage_limit`: How many times the promotion can be used before becoming
  inactive.
- `starts_at` and `expires_at`: Optional date values for the start and end of
  the promotion.
- `match_policy`: When set to `all`, all promotion rules must be met in order
  for the promotion to be eligible. When set to `any`, just one of the
  [promotion rules](#promotion-rules) must be met.
- `path`: If the promotion is activated when the customer visits a URL, this
  value is the path for the URL.
- `per_code_usage_limit`: Specifies how many times each code can be used before
  it becomes inactive.
- `apply_automatically`: If `true`, the promotion is activated and applied
  automatically once all of the [eligibility checks](#eligibility) have passed.

Note that you can access promotion information using the `promotion` method on
its associated `Spree::PromotionRule` and `Spree::PromotionAction` objects:

```ruby
Spree::PromotionAction.find(1).promotion
```

### Promotion handlers

Subclasses of the `Spree::PromotionHandler` model activate a promotion if the
promotion is [eligible](#eligibility) to be applied. There are `Cart`, `Coupon`,
`Page`, and `Shipping` subclasses, each one used for a different promotion
activation method. For more information, see the [Promotion
handlers][promotion-handlers] article.

Once a promotion handler activates a promotion, and all of the eligibility
checks pass, the `Spree::PromotionAction` can be applied to the applicable
shipment, order, or line item.

[promotion-handlers]: promotion-handlers.html

### Promotion rules

The `Spree::PromotionRule` model sets a rule that determines whether a promotion
is eligible to be applied. Promotions may have no rules or many different rules.

By default, `Spree::Promotion`s have a `match_policy` value of `all`, meaning
that all of the promotion rules on a promotion must be met before the promotion
is eligible. However, this can be changed to `any`.

An example of a typical promotion rule would be a minimum order total of $75
USD or that a specific product is in the cart at checkout.

For a list of available rule types and more information, see the
[Promotion rules][promotion-rules] article.

[promotion-rules]: promotion-rules.html

### Promotion actions

The `Spree::PromotionAction` model defines an action that should occur if the
promotion is activated and eligible to be applied. There can be multiple
promotion actions on a promotion.

Typically, a promotion action could be free shipping or a fixed percentage
discount.

A promotion action calculates the discount amount and creates a
`Spree::Adjustment` for the promotion. The adjustment then adjusts the price of
an order, line item, or shipment.

### Promotion adjustments

Finally, the `Spree::Adjustment` model defines the discount amount that is
applied. Each adjustment is created by a `Spree::PromotionAction`.

Every time that the promotion adjustment needs to be recalculated, the
`Spree::PromotionRule`s are re-checked to ensure the promotion is still
eligible.

Note that shipments and taxes can also create adjustments. See the [adjustments][adjustments]
documentation for more information.

[adjustments]: ../adjustments/overview.html

## Eligibility

`Spree::Promotion`'s performs a number of checks to determine whether a
promotion is eligible to be applied:

1. It checks that the promotion is active.
2. It checks that the promotion usage limit has not been reached.
3. It checks that the  promotion code usage limit has not been reached.
4. It checks that all of the products are promotable products.
5. Finally, it checks the `Spree::PromotionRule`s.

If all of these checks pass, then the promotion is eligible.

See the `eligible?` method defined in the [Spree::Promotion
model][spree-promotion]:

```ruby
# models/spree/promotion.rb
def eligible?(promotable, promotion_code: nil)
  return false if inactive?
  return false if usage_limit_exceeded?
  return false if promotion_code && promotion_code.usage_limit_exceeded?
  return false if blacklisted?(promotable)
  !!eligible_rules(promotable, {})
end
```

Note that promotions without rules are eligible by default.

Once the promotion is confirmed eligible, the promotion can be activated through
the relevant `Spree::PromotionHandler`.

[spree-promotion]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion.rb

## Promotion flow

This section provides a high-level view of the promotion system in action. For
the sake of this example, the store administrator is creating a free shipping
promotion for orders over $100 USD.

1. The administrator creates a `Spree::Promotion` from the Solidus backend.
  - They create a name, description, and optional category for the promotion.
  - They choose not to set a usage limit for the promotion.
  - They choose not to set a start or end date for the promotion.
  - They choose the "Apply to all orders" activation method. Alternatively, they
    could have chosen to apply promotions via a promotion code or a URL.
2. The administrator creates `Spree::PromotionRule`s for the promotion.
   - In this case, they use the rule type "Item Total"
     (`Spree::Promotion::Rules::ItemTotal`) and set the rule so that the
     order must be greater than $100 USD.
3. The administrator creates `Spree::PromotionAction`s for the promotion.
  - They use promotion action type "Free shipping", which uses the
    `Spree::Promotion::Actions::Shipping` model. In this case, the only
    available action is "Makes all shipments for the order free".
  - Because the promotion action requires a shipment, the
    `Spree::PromotionHandler::Shipping` will be used when it is time to activate
    the promotion.

Different types of promotions would change the customer's experience of
promotion activation. For example, the customer might be required to enter a
promotion code to activate some promotions, while another promotion could be
applied automatically.

In this case, because the administrator used the "Apply to all orders"
activation method, the promotion is applied automatically:

1. The customer adds items to their cart. The `Spree::Order` total is greater
   than $100 USD.
2. The customer begins the checkout process.
3. The customer enters their shipping information.
4. The `Spree::PromotionHandler::Shipping` handler checks that the
   `Spree::PromotionRule`s are met. Because the order total is
   greater than $100 USD, the promotion is eligible.
5. The `Spree::PromotionHandler::Shipping` activates the promotion.
6. The `Spree::PromotionAction` associated with the promotion is computed and
   applied as a `Spree::Adjustment` that negates the order's shipping charges.
   The customer's shipping is now free.
7. The customer completes the checkout process.
