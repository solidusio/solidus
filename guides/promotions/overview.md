# Overview

Promotions within Spree are used to provide discounts to orders, as well as to
add potential additional items at no extra cost. Promotions are one of the most
complex areas within Spree, as there are a large number of moving parts to
consider. Although this guide will explain Promotions from a developer's
perspective, if you are new to this area you can learn a lot from the Admin >
Promotions tab where you can set up new Promotions, edit rules & actions, etc. 

In some special cases where a promotion has a `code` or a `path` configured for
it, the promotion will only be activated if the payload's code or path match the
promotion's. The `code` attribute is used for promotion codes, where a user must
enter a code to receive the promotion, and the `path` attribute is used to apply
a promotion once a user has visited a specific path.

!!!
Path-based promotions will only work when the `Spree::PromotionHandler::Page`
class is used, as in `Spree::ContentController` from `spree_frontend`.
!!!

A promotion may also have a `usage_limit` attribute set, which restricts how
many times the promotion can be used.

## Eligibility

`Spree::Promotion`'s performs a number of checks to determine whether a
promotion is eligible to be applied.

First, it checks that the promotion is active, that its usage limit has not been
reached, that its promotion code usage limit has not be reached, and that all of
the products are promotable products. Finally, it checks the
`Spree::PromotionRule`s.

If all of these checks pass, then the promotion is eligible.

See the `eligible?` method defined in the [Spree::Promotion
model][spree-promotion]:

```ruby
# models/spree/promotion.rb : line 123
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
     promotion must be greater than $100 USD.
3. The administrator creates `Spree::PromotionAction`s for the promotion. 
  - They use promotion action type "Free shipping", which uses the
    `Spree::Promotion::Actions::Shipping` model. In this case, the only
    available action is "Makes all shipments for the order free".
  - Because the promotion action requires a shipment, the
    `Spree::PromotionHandler::Shipping` will be used when it is time to activate
    the promotion.

Different types of promotions would change the customer's experience of
promotion activation. For example, the customer might be required to enter a
promotion code to activate some promotions, while a free shipping promotion
would be applied automatically.

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
   applied as a `Spree::Adjustment` that negates the order's shipping charges..
   The customer's shipping is now free.
7. The customer completes the checkout process.
