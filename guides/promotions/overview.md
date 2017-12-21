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

