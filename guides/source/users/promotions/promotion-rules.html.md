# Promotion rules

Promotion rules determine whether a promotion is eligible to be applied.
Promotions let you control which customers can get promotional discounts and
which ones cannot. For example, you may want to offer a promotion that is only
valid for new customers.

Many conventional types of promotion rules are available in Solidus by default.
If you require a more specialized rule, speak with your developers about
creating one.

## Available promotion rule types

- **First Order**: Eligible for a customer's first order only.
- **First Repeat Purchase Since**: Eligible for a customer's first repeat
  purchase since a specified date.
- **Nth Order**: Eligible for a customer's *n*th order only.
- **Item Total**: Eligible if the order total (before any adjustments) is less
  than or greater than a specified amount.
- **One Use Per User**: Eligible for use one time per user.
- **Product(s)**: Eligible for specified products only.
- **Option Value(s)**: Eligible for specified variants (product option values)
  only.
- **Taxon**: Eligible for products with specified taxons.
- **User**: Eligible for specified users.
- **User Role**: Eligible for users with the specified user role.
- **User Logged In**: Eligible for users who are logged in.

## Eligibility

Every time a customer's order is updated, the promotion rules are re-checked to
ensure that the promotion is still valid. This protects your store from
customers who want to abuse promotion codes.

Every time the promotion rules are re-checked, any promotional discounts are
recalculated as well. For example, if the customer added more items to the cart,
those new items could now be calculated against the promotion rules.

## Rule matching

There are two types of rule matching in Solidus' promotion system: **Match all
of these rules** or **Match any of these rules**.

- **Match all of these rules**: This setting ensure that every rule must be
  matched before the promotion is applied. This is great if you only want to
  apply promotions for a very specific kind of order, like for first-time
  customers whose order is valued at $100 USD or more.
- **Match any of these rules**: This setting allows you to create more flexible
  promotions. For example, if you wanted to give a discount to customers who
  order your Tote Bag product *or* if it's their 5th order from your store.

