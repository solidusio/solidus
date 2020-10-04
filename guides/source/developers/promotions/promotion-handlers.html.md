# Promotion handlers

The [`Spree::PromotionHandler`][promotion-handler] handles promotion
activation. If the promotion is [eligible][eligibility], then the promotion can
be activated, and finally applied by the `Spree::PromotionAction`s associated
with the promotion.

Promotions can be activated in three different ways using subclasses of the
`Spree::PromotionHandler` model:

- `Cart`: Activates the promotion when a customer adds a product to their cart.
  In the Solidus backend, this is the handler used when an administrator assigns
  the activation method "Apply to all orders" to a promotion.
- `Coupon`: Activates the promotion when a customer enters a coupon code during
  the checkout process.
- `Page`: Activates the promotion when a customer visits a specific store URL.

[promotion-handler]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/promotion_handler/shipping.rb
[eligibility]: overview.html#eligibility

<!-- TODO:
  This article is a stub. If there's no reason to expand it, let's put it back
  into the overview.html article.

  I can see the coupon and page handlers becoming their own standalone articles.
-->
