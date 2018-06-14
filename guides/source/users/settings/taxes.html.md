# Taxes

When you go to the **Settings -> Taxes** page of the Solidus admin interface,
you can set up [tax categories](#tax-categories) and [tax rates](#tax-rates)
that help you tax customers according to the taxation laws in your region(s).

*Before you set up taxes in your store, you should set up [zones][zones], which
are locations that your store manages regarding shipping and taxes.*

## Tax categories

Each of your [products][products] has a **Tax Category** field. This allows you
to charge different tax rates for products, which you may need to do in order to
comply with your regional laws.

For example, if you have a stock location in California, any clothing you ship
within the state should be taxed. But any candy that you sell is tax exempt. You
may want to create a "Candy" tax category to handle your candy products that are
exempt from tax.

[products]: ../products/overview.html

### Tax category fields

When you create or edit a tax category, it uses the following settings:

- **Name**: The name for your tax category.
- **Tax Code**: An optional tax code that describes your tax category.
- **Default**: A checkbox that sets whether the current tax category should be
  used as the default tax category for new products.
- **Description**: An optional long description for your tax category.

## Tax rates

You can create tax rates that should be used for orders from [different states
or countries][zones], as well as for each of your tax categories. If your stores
have more complicated tax requirements, your tax rates can perform more complex
functions:

- You can create tax rates that calculate using sales tax (U.S.-style taxes) or
  value-added taxes ([VAT][vat], or E.U.-style taxes). Sales tax is applied on
  top of the price of each item, where as VAT is included in the price of each
  item.
- You can show or hide tax rates in customer invoices.
- You can create tax rates that are valid from a specific date.
- You can change the **Base Calculator** to [a custom tax
    calculator](#tax-calculators).

[vat]: https://en.wikipedia.org/wiki/Value-added_tax
[zones]: zones.html

### Create a tax rate

You can create a new tax rate in just a few steps:

1. Go to the **Settings -> Taxes** page of the Solidus admin interface.
2. Go to the **Tax Rates** page.
3. Select the **New Tax Rate** button.
4. Fill in the information for your new tax rate. See [Tax rate
   fields](#tax-rate-fields) for more information.
5. Select the **Create** button to save the new tax rate.

### Tax rate fields

When you add or edit a tax rate, the following settings are available:

- **Name**: The name for the tax rate. By default, customers can see the name of
    the tax rate during checkout.
- **Rate**: The tax rate as a decimal. For example, `0.05` would become a 5% tax
    rate.
- **Included in Price**: Sets whether the tax should be calculated as already
    included in price of items ([value-added tax][vat]) or should be calculated
    as sales tax on top of the price of items.
- **Zone**: The [zone][zones] where this tax rate applies.
- **Tax Category**: The [tax category](#tax-categories) that this tax rate
    should apply to.
- **Validity Period**: The start and end dates that this tax rate is valid to.
- **Base Calculator**: The tax calculator that should be used to calculate
    taxes. For more information, see [Tax calculators](#tax-calculators) below.

## Tax calculators

By default, Solidus includes a single tax calculator called **Default Tax**.
This calculator is suitable to calculate taxes for typical ecommerce
transactions around the world.

If your business has complicated tax requirements, you may want to have your
development team create a tax calculator that is suited specifically to your
store.
