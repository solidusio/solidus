# Custom shipping calculators

This article provides context about creating custom shipping calculators in the
case that the provided calculators do not meet your store's needs.

## Pre-configured calculators

Before developing a custom calculator, you should make sure that the calculator
you need doesn't already exist in Solidus or one of its extensions.

Solidus comes with a set of default calculators that account for typical
shipping scenarios:

- [Flat percent](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_percent_item_total.rb)
- [Flat rate (per order)](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_rate.rb)
- [Flat rate per package item](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/per_item.rb)
- [Flexible rate per package item](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flexi_rate.rb)
- [Price sack](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/price_sack.rb)

If the calculators that come with Solidus are not enough for your needs, you
might want to use an extension like
[`solidus_active_shipping`][solidus-active-shipping] that provides additional
API-based rate calculation functionality for common carriers like UPS, USPS, and
FedEx. Alternatively, you could develop your own custom calculator.

[solidus-active-shipping]: solidus-active-shipping-extension.html

## Custom calculator requirements

A custom calculator should accept a `Spree::Stock::Package` (a `package`) and
return a cost.

Use the `package.order` method to access the current order's information, and
the `package.contents` methods to access the current package's contents. As a
developer, you should always deal with the `package.contents`. Otherwise, you
may be quoting an entire order when you only want to quote one of many shipments
on an order.

<!-- TODO:
  So far, the shipments documentation doesn't go into packages in any details.
  These references by themselves are not enough. What is the purpose of a
  "package" that is distinctive from a "shipment".
-->

Typically, a calculator uses the following order information:

- The `Spree::Address` used as the order's shipping address.
- The `Spree::LineItem` objects associated with the order.
- The `Spree::Variant` product information (such as the weight and dimensions)
  associated with each line item in the order.

For an example of a typical calculator, we recommend reading the source code for
Solidus's [stock flat rate calculator][flat-rate-source].

For a more complicated example of what is possible with custom calculators, see
the [`solidus_active_shipping` base calculator][base-calculator-source]. This
calculator collects enough information about an order to send to a carrier and
get a rate quote back.

[flat-rate-source]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/shipping/flat_rate.rb
[base-calculator-source]: https://github.com/solidusio-contrib/solidus_active_shipping/blob/master/app/models/spree/calculator/shipping/active_shipping/base.rb

### Inherit from the `Spree::ShippingCalculator` class

Your custom shipping calculator should inherit from the existing
`Spree::ShippingCalculator` class. We recommend following the same directory
structure that Spree models do, so your new calculator would be created at:

```bash
/app/models/my_store/calculator/shipping/custom_shipping_calculator.rb
```

Then, follow the pattern of Spree's built-in calculators and inherit from
`Spree::ShippingCalculator`:

```ruby
module MyStore
  class Calculator::Shipping::CustomShippingCalculator < Spree::ShippingCalculator
  end
end
```

### Required methods

Your custom shipping calculator requires at least two methods:

1. A `self.description` method that provides a name for the custom calculator.
2. A `compute_package(package)` that provides the return value for a package
   being shipped.

For example:

```ruby
module MyStore
  class Calculator::Shipping::CustomShippingCalculator < Spree::ShippingCalculator
    def self.description
      "Custom Shipping Calculator"
    end

    def compute_package(package)
      12.00
    end
  end
end
```

<!-- TODO:
  This example code gets developers some of the way there, but could be improved
  to be more realistic. See the built-in shipping calculators for more realistic
  `compute_package` definitions.
-->

### Register the new shipping calculator

Once you have created the logic for the new shipping calculator, you need to
register it so that administrators can create new shipping methods that use the
custom calculator.

For example, you can register it in your `/config/initializers/spree.rb` initializer:

```ruby
# /config/initializers/spree.rb

Rails.application.config.spree.calculators.shipping_methods << MyStore::Calculator::Shipping::CustomShippingCalculator
```

## Calculator availability

By default, shipping calculators are always available to be used by shipping
methods. This is because the `available?` method on the base
[`Spree::Calculator` class][calculator-class] returns `true` by default.

You may want to make the calculator availability change depending on some aspect
of the current order. To do this, you can override the `available?` method in
your custom calculator:

```ruby
module MyStore
  class Calculator::Shipping::CustomShippingCalculator < Spree::ShippingCalculator
    ...

    def available?(order)
      order.currency == "USD"
    end
  end
end
```

For more information about availability and filtering shipping methods, see the
[Shipping method filters][shipping-method-filters] article.

[calculator-class]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator.rb
[shipping-method-filters]: shipping-method-filters.html

## Use additional product information

In addition to providing relevant information about shipping addresses and
product variants, you can use information about the product itself to inform a
calculator's results. A product's tax category or shipping category could be
meaningful information for shipping calculations. By default, each package
contains only items in the same shipping category.

For example, you might want your calculator to handle your product with a
shipping category of "Oversized" differently than it would a product with the
"Default" shipping category.

For example, you might want your calculator to handle products with different
shipping categories in specific ways: an product with the "Oversized" category
should not be treated like a product with the "Default" category.

<!-- TODO:
  Add an example code block or a link to some Solidus code that shows a
  calculator taking advantage of shipping categories and/or tax categories to
  produce a specific result.
-->
