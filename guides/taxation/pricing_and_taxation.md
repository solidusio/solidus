### Calculators

Every `Spree::TaxRate` has a `Spree::Calculator` that calculates the correct tax amount for a given shipment or line item. In most cases you should be able to use Solidus's `DefaultTax` calculator. It is suitable for both Sales tax and VAT scenarios.

If you want or need to change the default tax calculation behavior, please  have a look at the [Default Tax Calculator Specs](https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/calculator/default_tax_spec.rb) or its [implementation](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/default_tax.rb).

## Pricing

In VAT-style jurisdictions prices have to be shown including the taxes to customers. That's even true for all index and product display pages as well as when items are added to the cart, not only during the check out.

In order to comply with this requirement, you first need to configure your tax rates, tax categories, and zones, then update your products and variants with the "Rebuild VAT prices" checkbox checked.

Solidus will then proceed to calculate the correct net price and create prices for all countries with `included_in_price` VAT rates. It will also generate a fallback "export" price, where the prices `country_iso` is `nil` (not set). New products will behave as if that checkbox is checked. You can adjust the prices in the "Prices" tab if you need to.

Solidus can handle several prices for the same country, and will always select the most recently updated price.

## Prices in the backend

In the Solidus admin backend, prices will be displyes including any VATs valid for the country represented by the configuration value `Spree::Config.admin_vat_country_iso`.

Admin users in a country with VAT expect backend prices to include their home country's VAT. For example, if your admins reside in Germany, you will want to set `Spree::Config.admin_vat_country_iso` to `"DE"`. The effect of this is that now all prices in the backend can be assumed to include German VAT rates.

## Prices in the frontend

When a customer first browses your store, we do not know which jurisdiction she lives in. We will, therefore, have to make an assumption about her whereabouts. This assumption is the `cart_tax_country_iso` property on the `Spree::Store` model - meaning that you can assume your customers to be from different countries depending on which store she browses. Remember the requirement to display the prices including VAT from above? This is how you comply to this.

You can have more than one store. For example, two different stores for France and Germany (`my-shop.com/fr` and `my-shop.com/de`), where each store shows different prices to account for different VAT rates in either country.

***
You can customize Solidus' pricing behaviour by creating a custom `Spree::Config.variant_price_selector_class` along with a fitting `Spree::Config.pricing_options_class`.
See the [specifications](https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/variant/price_selector_spec.rb) for the standard [Price Selector](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/variant/price_selector.rb) as well as the [specifications](https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/variant/pricing_options_spec.rb) for the standard [Pricing Options](https://github.com/solidusio/solidus/blob/master/core/app/models/spree/variant/pricing_options.rb) for inspiration.
***

## Examples

### Sales Tax

Let's say you need to charge 5% additional ("Sales") tax for all items that ship to New York and 6% on clothing items that ship to Pennsylvania. This will mean you need to construct two different zones: one zone containing just the state of New York and another zone consisting of the single state of Pennsylvania. You'll also need to create two tax categories ("All items" and "Clothing"), mark your products accordingly, and create a tax rate for "all items" in New York, and a tax rate for "clothing" in Pennsylvania.

## Examples

Let's take an example of a sales tax situation for the United States. Imagine that we have a zone that covers all of North America and that the zone is used for a tax rate which applies a 5% tax on products with the tax category of "Clothing".

If the customer purchases a single clothing item for $17.99 and they live in the United States (which is within the North America zone we defined) they are required to pay sales tax.

The sales tax calculation is $17.99 x 5% for a total tax of $0.8995, which is rounded up to two decimal places, to $0.90. This tax amount is then applied to the line item as an adjustment and added on top of the order total.

If the quantity of the item is changed to 2, then the tax amount doubles: ($17.99 x 2) x 0.05 is $1.799, which is again rounded up to two decimal places, applying a tax adjustment of $1.80.

Let's now assume that we have another product that's a coffee mug, which doesn't have the "Clothing" tax category applied to it. Let's also assume this product costs $13.99, and there's no default tax category set up for the system. Under these circumstances, the coffee mug will not be taxed when it's added to the order.

### VAT-Style taxation

Many jurisdictions have what is commonly referred to as a Value Added Tax (VAT). In these cases the tax is typically already included in the price. This means that no additional tax needs to be applied during checkout.

When tax is included in the price adjustments do not affect the order total (unlike the sales tax case). Stores are, however, usually required to show the amount of tax the user paid. That's why Solidus lists all adjustments below the item total on the checkout summary page.

Let's start by looking at an example where there is a 5% VAT on all products. We'll further assume that this tax should only apply to orders within the United Kingdom (UK).

In the case where the order address is within the UK and we purchase a single clothing item for &pound;17.99 we see an order total of &pound;17.99. The tax rate adjustment applied is &pound;17.99 x 5%, which is &pound;0.8995, and that is rounded up to two decimal places, becoming &pound;0.90.

Now let's increase the quantity on the item from 1 to 2. The order total changes to &pound;35.98 with a tax total of &pound;1.799, which is again rounded up to now being &pound;1.80.

Next we'll add a different clothing item costing &pound;19.99 to our order. Since both items are clothing and taxed at the same rate, they can be reduced to a single total, which means there's a single adjustment still applied to the order, calculated like this: (&pound;17.99 + &pound;19.99) x 0.05 = &pound;1.899, rounded up to two decimal places: &pound;1.90.

Now let's assume an additional tax rate of 10% on a "Consumer Electronics" tax category. When we add a product with this tax category to our order with a price of &pound;16.99, there will be a second adjustment added to the order, with a calculated total of &pound;16.99 x 10%, which is &pound;1.699. Rounded up, it's &pound;1.70.

### Different tax rates by tax category for the same zone

Here's another scenario. You would like to charge 10% tax on all electronic items and 5% tax on everything else. This tax should apply to all countries in the European Union (EU). In this case you would construct just a single zone consisting of all the countries in the EU. To differentiate between "electronic" items and "other" items, use tax categories. Now setup two tax rates with the "EU" zone, and their respective tax categories. The fact that you want to charge two different rates depending on the type of good does not mean you need two zones.

## Acknowledgements

Parts of this guide were originally written as the [Spree guide on taxation](https://github.com/spree/spree-guides/blob/master/content/developer/core/taxation.md) with contributions by @danabrit, @radar, @gwagener and @brchristian.
