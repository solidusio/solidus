# Overview

All calculators in Solidus inherit from the `Spree::Calculator` base class. They
calculate and return the value of promotions, taxes, and shipping charges.
Solidus includes built-in calculators for common types of calculations, such as
flat rate shipping, percentage discounts, sales tax, and value-added tax (VAT).

Whenever you create a new shipping method, tax rate, or promotion action, you
also create a new instance of a `Spree::Calculator`.

For example, if you create a new shipping method called "USPS Ground" that
charges a flat rate of $10 USD, you would be creating an instance of the
`Spree::Calculator::Shipping::FlatRate` calculator:

- The new calculator instance would have `calculable_type` of
  `Spree::ShippingMethod`. This is because it has a polymorphic relationship
  with a shipping method, rather than a tax rate or promotion action. See
  [calculables](#calculables) for more information about this relationship.
- The new calculator instance's `preferences` attribute would have a value of
  `{:preference=>10, :currency=>"USD"}`.

## Attributes

`Spree::Calculator` objects have the following attributes:

- `type`: The type of calculator being used. For example, if the object
  calculates shipping, it could be any available shipping calculator, such as
  `Spree::Calculator::Shipping::FlatRate`.
- `calculable_type` and `calculable_id`: The calculable type and its matching
  ID. For example, if the object calculates shipping, the calculable would be
  from the `Spree::ShippingMethod` model. See [calculables](#calculables) for
  more information.
- `preferences`: A hash of the calculator's preferences and the values of those
  preferences. Each type of calculator has its own preferences. See
  [preferences](#preferences) for more information.

## Calculables

A calculable is an object that needs to be calculated by a `Spree::Calculator`.
In Rails, this is an example of a [polymorphic association][rails-polymorphic]:
all calculators share a common base class, but they can calculate different
types of objects.

In the case of `Spree::Calculator`s, there are three different
`calculable_types`:

- `Spree::ShippingMethod`
- `Spree::TaxRate`
- `Spree::PromotionAction`

A calculable `include`s the `Spree::CalculatedAdjustments` module. This module
requires that each calculable has one calculator object. So, for each calculable
object, an instance of a `Spree::Calculator` should also be created.

For example, a shipping method called "USPS Ground" charges a flat rate of $10
USD. The shipping method is calculable and requires an associated calculator.
So, the rate for each shipment is calculated by the associated
`Spree::Calculator::Shipping::FlatRate` object.

Similarly, each tax rate in your store is calculable. So, instance of the
`Spree::Calculator::DefaultTax` calculator is created and calculates the amount
of tax that should be applied to line items, shipments, or orders.

[rails-polymorphic]: http://guides.rubyonrails.org/association_basics.html#polymorphic-associations

## Preferences

Each `Spree::Calculator` has [static model preferences][model-preferences]. Each
instance of a calculator has a `preferences` attribute that stores a hash of
preferences.

For example, you may have two flat shipping rates configured in your store.
If you look up each of  your `Spree::Calculator::Shipping::FlatRate` calculators,
you can see how the static preferences have different settings:

```ruby
Spree::Calculator::Shipping::FlatRate.find(1).preferences
# => {:amount=>8, :currency=>"USD"}

Spree::Calculator::Shipping::FlatRate.find(2).preferences
# => {:amount=>4, :currency=>"EUR"}
```

Because each type of calculator has different functionality, each calculator has its own
set of preferences.

For example, a calculator that uses a percentage for calculations would not have
a `:currency` preference, but any calculator that uses a specific amount of
currency would have a `:currency` preference::

```ruby
Spree::Calculator::Shipping::FlatRate.find(2).preferences
# => {:amount=>4, :currency=>"EUR"}

Spree::Calculators::Shipping::FlatPercentItemTotal.find(3).preferences
# => {:flat_percent=>0.2e1}
```

[model-preferences]: ../preferences/add-model-preferences.html

### Preferred methods

For each preference on a calculator, you can use a `preferred_<preference>`
method to get or set the value of the preference (where `<preference>` is the
name of the preference). For example

```ruby
Spree::Calculator.find(1).update(preferred_amount: 20)
```

<!-- TODO:
  Add more detail about preferences. For example: a list of common preference or
  example code in which a custom preference is created.
-->

## Custom calculators

If Solidus's built-in calculators are not sufficient for your store, you can
create your own custom calculators. Because promotion, shipping, and tax
calculators have different requirements, we have an article describing each type
of custom calculator you may want to build:

- Custom promotions calculator [Note: work in progress]
- [Custom shipping calculators][custom-shipping-calculators]
- [Custom tax calculators][custom-tax-calculators]

[custom-shipping-calculators]: ../shipments/custom-shipping-calculators.html
[custom-tax-calculators]: ../taxation/custom-tax-calculators.html
