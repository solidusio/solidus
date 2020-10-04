# Overview

Solidus's taxation system supports both sales- and VAT-style taxes. You can use
tax rates, tax categories, and the built-in tax calculator to handle your
store's tax logic. Solidus uses the `Spree::Adjustment` model to apply taxes to
orders. This way, there can be multiple tax adjustments applied to each order.

Using adjustments helps account for some of the complexities of tax, especially
if a store sells internationally:

- Orders may include products with different tax categories or rates.
- Shipments may require special calculations if you are shipping to or from
  locations where there are specific taxation rules for shipments.
- Taxes may or may not be included in a product's price depending on a country's
  taxation rules.

<!-- TODO:
  - Add links to the locations guide and specifically the [zones](#) article.
  - Add links to the adjustments guide.
-->

Solidus uses the `Spree::TaxCategory` and `Spree::TaxRate` models to specify the
rules for how tax adjustments are calculated. Tax adjustments are created for
each line item in an order. 

See the [Order taxation](#order-taxation) section for an overview of the order
taxation process.

## Tax categories

Tax categories can be used to ensure particular products are taxed as required.
For example, if your business is based in Minnesota, you need to charge tax on
tech products but do not need to charge tax on clothing. You could set up two
tax categories, **Clothing** and **Tech** which you would apply to products of
either type.

By default, new products do not have a set tax category. Administrators can set
the tax category while creating the product or set it later while editing the
product. 

## Tax rates

Tax rates define the amount of tax that should be charged on items. You might
configure different tax rates for different zones and tax categories, or even
for specific dates. You could also create more complex tax rates with a custom
tax calculator.

In Solidus, a tax rate consists of at least four values:

- The descriptive name for the tax rate. For example, "Minnesota Sales Tax" for
  a Minnesota state tax rate.
- The [zone][zone] that the tax rate should apply to.
- The rate (in the form of a percentage of the price).
- The "Included in price" boolean. This indicates whether the tax is included in
  the price (for value-added taxes) or added to the price (U.S. taxes).

Solidus calculates tax based on the matching tax rate(s) for the order's [tax
address](#tax-addresses).

[zone]: ../locations/zones.html

## Tax addresses

If an order's `tax_address` falls within a specific zone, the tax rates that you
have configured would apply for all the line items and shipments in that zone
that have a matching tax category.

By default, the `tax_address` used for orders is the customer's shipping
address. This is how most tax jurisdictions require taxes to be calculated. 
However, you can configure your store to globally use customer billing
addresses instead in any initializer file inside the `config/initializers/`
directory:

```ruby
Spree::Config[:tax_using_ship_address] = true
```

### Use `Spree::TaxLocation` as the tax address

An order's `tax_address` can – through [duck typing][duck-typing] – be a
`Spree::Tax::TaxLocation` instead of the shipping address. The tax location is
computed from the store's `Spree.config.cart_tax_country_iso` setting.

Note that you can only trust the tax address if it has a country. The other
address fields might be empty or raise errors.

<!-- TODO:
  Note that the `tax_using_ship_address` configuration is likely to be
  deprecated in the future.
-->

[duck-typing]: https://en.wikipedia.org/wiki/Duck_typing

## Sales tax and value-added tax

In ecommerce, [consumption tax][consumption-tax] either takes the form of sales
tax or value-added tax. Some countries use other names for their taxes, but
generally all modern consumption taxes would be considered one of these two
types.

Solidus's models support both types of taxes. In the case of a product or
shipment:

- **Sales tax** is calculated as _additional_ taxes on top of the listed price.
  (U.S.-style taxation.)
- **Value-added tax (VAT)** is calculated as _included_ in the listed price.
	Solidus lists all VAT amounts below the item total on checkout summary pages.
	For more information about VAT, see [Value-added tax (VAT)][vat].

[consumption-tax]: https://en.wikipedia.org/wiki/Consumption_tax
[vat]: value-added-tax.html

### Tax in the United States

Note that sales tax in the United States can get exceptionally complex. Each
state, county, and municipality might have a different tax rate.

<!-- TODO:
  Create and link to an article that's all about United States taxes.
-->

If you intend to ship products between states, and your store is based in the
United States, we recommend that you use an external service like
[Avatax][avatax] or [Tax Cloud][tax-cloud] to automate your U.S. tax rates.
Solidus has extensions for both of these services:
[`solidus_avatax_certified`][solidus-avatax-certified] and
[`solidus_tax_cloud`][solidus-tax-cloud].

[avatax]: https://www.avalara.com/
[tax-cloud]: https://taxcloud.net/
[solidus-avatax-certified]: https://github.com/boomerdigital/solidus_avatax_certified
[solidus-tax-cloud]: https://github.com/solidusio-contrib/solidus_tax_cloud

## Order taxation

Once the order has a `tax_address` specified, tax can be calculated for all of
the line items and shipments associated with a `Spree::Order`:

Note that any promotional adjustments are applied before tax adjustments. This
is to comply with tax regulations for value-added taxation [as outlined by the
Government of the United Kingdom][uk-vat-discounts] and for sales tax [as
outlined by the California State Board of Equalization][ca-tax-discounts].

1. Solidus iterates over all of the order's line items. It selects the
   tax rates that match each item's tax category.
2. For each line item, the tax rate (a percentage value) is multiplied with the
   item's `amount` value. (`price ✕ quantity ➖ promotions`.)
3. The calculated amounts are stored in a `Spree::Adjustment` object that is
   associated with the order's ID.
4. The line item's `included_tax_total` or `additional_tax_total` are updated.
   (If the `Spree::TaxRate`'s `included_in_price` value is set to `true`,
   Solidus uses the `included_tax_total` column to store the sum of VAT-style
   taxes. Otherwise, it uses the `additional_tax_total` to store the sum of
   sales tax-style taxes.)
5. The same process is executed on the order's `Spree::Shipments`.  
6. The sum of the `included_tax_total` and `additional_tax_total` on all line
   items and shipments a stored in the order's `included_tax_total` and
   `additional_tax_total` values.

The `included_tax_total` column does not affect the order's total, while the
`additional_tax_total` does.

Every time an order is changed, the taxation system checks whether tax
adjustments need to be changed and updates all of the taxation-relevant totals.

See the [taxation integration spec][taxation-spec] for more information on
Solidus's taxation system.

[uk-vat-discounts]: https://www.gov.uk/vat-businesses/discounts-and-free-gifts#1
[ca-tax-discounts]: http://www.boe.ca.gov/formspubs/pub113/
[taxation-spec]: https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/tax/taxation_integration_spec.rb
