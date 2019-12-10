# Value-added tax (VAT)

Many countries have what is referred to as a value-added tax (VAT). When a
country uses VAT, tax is included in the price of each item. This means that
no additional tax needs to be applied during checkout. However, most tax
jurisdictions still require stores to show the amount of VAT that the customer
paid.

In the admin, the **Settings -> Taxes -> Tax Rates** page allows administrators
to create any tax rate. They can create VAT-style taxes by using the "Included
in price" checkbox.

Solidus's `solidus_frontend` gem lists all of the VAT and other price
adjustments below the item total on the checkout summary page.

## Calculating VAT

When you set up products in Solidus, you can set the price to the exactly what
you want the customer to pay. Then, you can use your VAT-style tax rates to
allocate a percentage of the gross price to taxes.

```
consumer_price / (1 + tax_rate) = expected_revenue
consumer_price - expected_revenue = vat
```

Solidus's [Spree::Calculator::DefaultTax][default-tax-calculator] handles
sales tax and VAT. If a tax rate is VAT and should be included in the price, it
calculates all of the line items that share that tax rate on the order:

```
if rate.included_in_price
  round_to_two_places(line_items_total - ( line_items_total / (1 + rate.amount) ) )
...
end
```

[default-tax-calculator]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/default_tax.rb

### VAT amounts are stored in `Spree::Adjustment`s

Note that while VAT does not adjust an order's total, Solidus still creates
`Spree::Adjustment` objects to store tax amount. These objects have an
`included` value of `true` so that the tax is not added to the price.

## Example order with multiple VAT rates

In the following example, we will still refer to VAT as "adjustments",
since that is how Solidus stores the tax amounts.

Our United Kingdom-based company is required to follow these tax regulations:

- Items of clothing should be taxed at a 5% rate.
- Consumer electronics should be taxed at a 10% rate.
- We are required to display the VAT paid to the customer.

If a customer orders a single clothing item:

- A customer within the UK adds one £17.99 t-shirt to their order.
- The tax calculator calculates the VAT: `17.99 - (17.99 / (1 + 0.05)) = 0.86`.

```
  £17.99 – 1 x T-shirt
  £0.86 – Clothing tax (5%)

  £17.99 – TOTAL
```

If a customer adds a second clothing item to the order:

- The customer adds a £19.99 t-shirt to the existing order.
- The total cost for the two items is £37.98.
- Because the order only includes clothing items, the included tax is calculated
	as a single adjustment (5%).
- The tax calculator calculates the VAT: `37.98 - (37.98 / (1 + 0.05)) = 1.81`.

```
  £17.99 – 1 x T-shirt
  £19.99 – 1 x T-shirt
  £1.81 – Clothing tax (5%)

  £37.98 – TOTAL
```

If a customer adds a consumer electronics product to the order:

- The customer adds a £16.99 power adapter to the existing order.
- The total cost for the three items is £54.97.
- Because the order includes both clothing items and consumer electronics, the
	tax must be calculated as two adjustments at two different tax rates.
- The tax calculator calculates the VAT for the clothing items: `37.98 - (37.98
  / (1 + 0.05)) = 1.81`.
- The tax calculator calculates the VAT for the consumer electronics item:
  `16.99 - (16.99 / (1 + 0.10)) = 1.54`.

We can now show the display the final included VAT in the price when the
UK-based customer arrives at the checkout summary page:

```
  £17.99 – 1 x T-shirt
  £19.99 – 1 x T-shirt
  £16.99 – 1 x Power adapter
   £1.81 – Clothing tax (5%)
   £1.54 – Consumer electronics tax (10%)

  £54.97 – TOTAL
```

## Customize your VAT generation

If the provided model in core does not fit your business needs, you
can easily customize the VAT generation logic by defining your own
VAT generator class. Let's walk into this with an example:

Let's suppose you need to show the same gross price across different
countries, no matter what the VAT is but still keeping the VAT tax
to be visible in checkout.

You need to customize the logic used by Solidus to generate the price
in countries that use VAT (with a TaxRate that has `included_in_price`
set to `true`).

### Create your own VAT Prices Generator class

You can create your own class that implements this logic. It has to be
compliant with the interface of the class provided by default in Solidus
core, which is [Spree::Variant::VatPriceGenerator][Spree::Variant::VatPriceGenerator].

We suggest to inherit from that class and override only the method that
you need to be different, for example:

```ruby
# app/spree/variant/custom_vat_price_generator.rb

# frozen_string_literal: true

module Spree
  class Variant < Spree::Base
    class CustomVatPriceGenerator < VatPriceGenerator
      def run
        # Early return if there is no VAT rates in the current store.
        return if !variant.tax_category || variant_vat_rates.empty?

        country_isos_requiring_price.each do |country_iso|
          # Don't re-create the default price
          next if variant.default_price && variant.default_price.country_iso == country_iso

          foreign_price = find_or_initialize_price_by(country_iso, variant.default_price.currency)
          foreign_price.amount = variant.default_price.amount
        end
      end
    end
  end
end
```

Now that you have created your custom class, you can easily ask Solidus to
use it, by setting the following configuration in an initializer:

```ruby
Spree::Config.variant_vat_prices_generator_class = 'Spree::Variant::CustomVatPriceGenerator'
```

[Spree::Variant::VatPriceGenerator]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/variant/vat_price_generator.rb
