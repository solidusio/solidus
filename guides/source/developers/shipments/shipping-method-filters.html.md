# Shipping method filters

While shipping method filters occur automatically, your store may require
additional shipping method filtering.

## Default behavior

Shipping methods are automatically filtered by zone. This means that once the
customer provides a shipping address during checkout, the shipping methods that
the customer can choose from are limited to the shipping methods available in
their region.

For example, if your store does not have a zone that includes the United
Kingdom, then a customer cannot complete the checkout process if their shipping
address is within the United Kingdom.

## Shipping method availability

The base `Spree::Calculator`'s `available?` method returns `true` by default.

<!-- TODO:
  Show how Solidus's default shipping method filtering works. Find out why, when
  the zone and the shipping address don't match, `available?` returns `false`.
-->

You can see the `shipping_methods` being filtered out in the
`Spree::Stock::Estimator` class below:

```ruby
class Spree::Stock::Estimator
  def shipping_methods(package)
    shipping_methods = package.shipping_methods

    shipping_methods.delete_if do |ship_method|
      !ship_method.calculator.available?(package.contents)
    end

    shipping_methods.delete_if do |ship_method|
      !ship_method.include?(order.ship_address)
    end

    shipping_methods.delete_if do |ship_method|
      !(ship_method.calculator.preferences[:currency].nil? ||
      ship_method.calculator.preferences[:currency] == currency)
    end

    shipping_methods
  end
end
```

<!-- TODO:
  This isn't what the Spree::Stock::Estimator class actually looks like. Would
  this really be how anyone goes about modifying this class, anyway?
-->

## Add additional criteria to filter by

Consider a custom "USPS Bogus First Class International" delivery service. This
service is only available if the shipment weighs less than 10lbs.

We want to ensure that "USPS Bogus First Class International" shipping is not
available when orders weigh more than 10lbs. So, we want to set our shipping
calculator's `available?` method to return `false` if the collective weight of
an order's line items are greater than 10lbs:

```ruby
class Calculator::Usps::FirstClassMailParcels < Calculator::Usps::Base
  def self.description
    "USPS Bogus First Class International"
  end

  def available?(package)
    multiplier = 1.3

    weight = order.line_items.inject(0) do |weight, line_item|
      line_item_weight = line_item.variant.weight
      weight + (line_item_weight ? (line_item.quantity * line_item_weight * multiplier) : 0)
    end

    # If weight in oz  > 13, then "USPS Bogus First Class International" is not
    # available for the order
    weight > 13 ? false : true
  end
end
```
