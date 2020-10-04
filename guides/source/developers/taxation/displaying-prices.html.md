# Displaying prices

Solidus allows you to display prices in a flexible way to comply with your local
tax regulations.

For example, in most countries that use value-added taxes (VAT), prices in a
store's frontend need to include any taxes that will be charged to the customer.

## Set up price display for value-added taxes (VAT)

In order to comply with VAT-style tax regulations, you first need to set up the
tax rates, tax categories, and zones that your store will use in production.

After you have set up and tested your store's tax configuration options, you can
update any of your existing products and variants with the "Rebuild VAT prices"
checkbox selected.

Solidus can then proceed to calculate the correct consumer prices for each
country with `included_in_price` VAT rates. It also generates a fallback
"export" price, where the price's `country_iso` is `nil`. New products will
behave as if the "Rebuild VAT prices" checkbox were selected.

If you update your tax configuration in the future, you will need to rebuild
your VAT prices again.

Any product can have several prices for the same country. By default, Solidus
always uses the most recently updated price.

## VAT is always included in backend prices

In countries that use VAT, administrators expect backend prices to include their
country's VAT.

If you use the `solidus_backend` gem for store administration, all your prices
are displayed including any valued-added tax (VAT) valid for the current
country.

You can change the configured country represented in your admin using the Spree
`admin_vat_country_iso` configuration value. For example, if the store
administrator lives in Germany, you could change the configured value to the
ISO code for Germany:

```ruby
Spree::Config.admin_vat_country_iso = "DE"
```

## Anticipate the customer's tax jurisdiction

When a customer first browses your store, you may not know which tax
jurisdiction they live in. You can choose to make an assumption about your
customers's location using the `Spree::Store` model's `cart_tax_country_iso`
property.

The `cart_tax_country_iso` property sets a default location for customers
depending on the store that they are browsing. For example, if you have both a
`us.store.com` and a `de.store.com` and the customer is browsing the
`us.store.com`, your customer is more likely to be in the United States.

Using the `cart_tax_country_iso` property can help you comply with tax
jurisdictions where it is required to display VAT as part of the price.

Administrators can configure these values for a storefront using the "Default
currency" and "Tax Country for Empty Carts" settings on the **Settings ->
Store** page in the `solidus_backend` admin.

Valued-added tax and price are intricately connected. If your store requires
custom tax and pricing logic, you can change Solidus's pricing behavior by
creating a custom `Spree::Config.variant_price_selector_class` along with a
fitting `Spree::Config.pricing_options_class`. See the [`price_selector`
specifications][price-selector-spec] for the standard [price
selector][price-selector], as well as the [`pricing_options`
specifications][pricing-options-spec] for the standard [pricing
options][pricing-options] for more information.

<!-- TODO:
  We could optionally create a tutorial article for setting up multiple
  storefronts and creating custom pricing behavior.
-->

[pricing-options]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/variant/pricing_options.rb
[pricing-options-spec]: https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/variant/pricing_options_spec.rb
[price-selector]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/variant/price_selector.rb
[price-selector-spec]: https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/variant/price_selector_spec.rb
