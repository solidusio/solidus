# Promotion rules

Promotion rules determine whether a promotion can be applied to an order.
Promotions are only *eligible* if it meets all of the rules that have been
configured for it.

For example, if the promotion associated with your promotion code `TSHIRT10`
should only be applied when a customer has a t-shirt product in their cart, you
can use rules to enforce this behavior. Then, the promotion is only eligible
once a t-shirt is in the customer's cart.

Because you may want to make simple promotions and complex promotions,
promotions may have no rules, a single rule, or many rules that need to be
enforced.

You can mix and match [many types of promotion
rules](#available-promotion-rule-types) for total control over your store's
promotions.

## Promotion rule matching

When you create a promotion and start to set up promotion rules, you can set the
promotion to **Match any of these rules** or **Match all of these rules**. Use
this setting to make your promotions more flexible and powerful.

This setting allows you to create multi-rule promotions that can be applied to
many, generic orders or only a few, very specific orders. 

<!-- TODO: Add screenshot of rule matching radiobuttons. -->

## Available promotion rule types 



Solidus provides many promotion rule types that you can use to create promotion
rules:

- **Item total**: Eligible if the order total (before
  [adjustments][adjustments]) is less than or greater than the set amount.
- **User**: Eligible for a specific customer or specific customers.
- **First order**: Eligible only if it is the customer's first order with your
  store.
- **User Logged In**: Eligible only if the customer is logged into their
  customer account.
- **One Use Per User**: Eligible to be used by a customer one time only.
- **Taxon(s)**: Eligible for [products with a specific taxon][taxons].
- **Nth Order**: Eligible for the customer's *n*th order, where *n* is a number
  that you set.
- **Option Value(s)**: Eligible only for product variants with [specific option
  values][option-types] that you choose.
- **First Repeat**: Eligible for a customer's first repeat purchase since a date
  that you set.
- **User Role(s)**: Eligible only for a user with a specific user role. For
  example, you may want to offer an employee discount to your store
  administrator accounts only.
- **Store**: Eligible only if the customer is using the store or stores that you
  choose. This promotion rule only applies to Solidus applications that manage
  multiple stores. 

[adjustments]: ../adjustments/overview.md
[option-types]: ../products/option-types.md
[taxons]: ../products/taxonomies.md
