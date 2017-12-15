# Adjustments

## Overview

An `Adjustment` object tracks an adjustment to the price of an [Order](orders),
an order's [Line Item](orders#line-items), or an order's [Shipments](shipments)
within a Spree Commerce storefront.

Adjustments can be either positive or negative. Adjustments with a positive
value are sometimes referred to as "charges" while adjustments with a negative
value are sometimes referred to as "credits." These are just terms of
convenience since there is only one `Spree::Adjustment` model in a storefront
which handles this by allowing either positive or negative values.

Adjustments can either be considered included or additional. An "included"
adjustment is an adjustment to the price of an item which is included in that
price of an item. A good example of this is a GST/VAT tax. An "additional"
adjustment is an adjustment to the price of the item on top of the original item
price. A good example of that would be how sales tax is handled in countries
like the United States.

Adjustments have the following attributes:

* `amount` The dollar amount of the adjustment.
* `label`: The label for the adjustment to indicate what the adjustment is for.
* `eligible`: Indicates if the adjustment is eligible for the thing it's
  adjusting.
* `mandatory`: Indicates if this adjustment is mandatory; i.e that this
  adjustment *must* be applied regardless of its eligibility rules.
* `state`: Can either be `open` or `closed`. Once an adjustment is closed, it
  will not be automatically updated.
* `included`: Whether or not this adjustment affects the final price of the item
  it is applied to. Used only for tax adjustments which may themselves be
included in the price.

Along with these attributes, an adjustment links to three polymorphic objects:

* A source
* An adjustable

The *source* is the source of the adjustment. Typically a `Spree::TaxRate`
object or a `Spree::PromotionAction` object.

The *adjustable* is the object being adjusted, which is either an order, line
item or shipment.

Adjustments can come from one of two locations within Spree's core:

* Tax Rates
* Promotions

An adjustment's `label` attribute can be used as a good indicator of where the
adjustment is coming from.

## Adjustment scopes

You can call [scopes][rails-scopes] on `Spree::Adjustment`s themselves or on any
class that has an `adjustments` association – like orders, line items, and or
shipments.

For example, you can find all of the adjustments with an `eligible` value of
`true` for orders, line items, and shipments:

- `Spree::Order.find(1).adjustments.eligible`: Returns all of the eligible
  adjustments on the order with the ID `1`.
- `Spree::LineItem.find(1).adjustments.eligible`: Returns all of the eligible
  adjustments on the line item with the ID `1`.
- `Spree::Shipment.find(1).adjustments.eligible`: Returns all of the eligible
  adjustments on the shipment with the ID `1`.

### List of adjustment scopes

- `tax`: Returns adjustments sourced from a `Spree::TaxRate` object.
- `price`: Returns adjustments that adjust a `Spree::LineItem` object.
- `shipping`: Returns adjustments that adjust a `Spree::Shipment` object.
- `promotion`: Returns adjustments sourced from a `Spree::PromotionAction`
   object.
- `return_authorization`: Returns adjustments sourced from a
  `Spree::ReturnAuthorization` object.
- `eligible`: Returns adjustments that are `eligible` to adjust the adjustable
  object that they are associated with. For example, if a tax adjustment is
  eligible, it would be successfully applied to its line item.
- `charge`: Returns adjustments with a positive value.
- `credit`: Returns adjustments with a negative value.
- `is_included`: Returns adjustments that are included in the object's price.
   Typically, only value-added tax adjustments have this value.
- `additional`: Adjustments which modify the object's price. The default for all
  adjustments.

<!-- TODO:
  Add link to taxation documentation to `is_included` item in the list.
-->

[rails-scopes]: http://guides.rubyonrails.org/active_record_querying.html#scopes

## Adjustment associations

`Spree::Order`s, `Spree::LineItem`s, and `Spree::Shipment`s are all
[adjustables](#adjustables).

To retrieve these adjustments on an order, call the `adjustments`
association:

```ruby
Spree::Order.find(1).adjustments
```

If you want to retrieve the line item adjustments, you can use the
`line_item_adjustments` method:

```ruby
Spree::Order.line_item_adjustments
```

Or, if you want to retrieve the shipment adjustments, you can use the
`shipment_adjustments` method:

```ruby
Spree::Order.shipment_adjustments
```

Finally, if you want to retrieve all of the adjustments on the order, you can
use the `all_adjustments` method.

```ruby
Spree::Order.all_adjustments
```

