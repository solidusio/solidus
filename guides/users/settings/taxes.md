# Taxes

When you go to the **Settings -> Taxes** page of the Solidus admin interface,
you can set up [tax categories](#tax-categories) and [tax rates](#tax-rates)
that help you tax customers according to the taxation laws in your region(s).

## Tax categories

Each of your [products][products] has a **Tax Category** field. This allows you
to charge different tax rates for products, which you may need to do in order to
comply with your regional laws.

For example, if you have a stock location in California, any clothing you ship
within the state should be taxed. But any candy that you sell is tax exempt. You
may want to create a "Candy" tax category to handle your candy products that are
exempt from tax.

When you create or edit a tax category, it uses the following settings:

- **Name**: The name for your tax category. 
- **Tax Code**: An optional tax code that describes your tax category.
- **Default**: A checkbox that sets whether the current tax category should be
  used as the default tax category for new products.
- **Description**: An optional long description for your tax category.

[products]: ../products/overview.md

## Tax rates

You can create tax rates that should be used for orders from [different states
or countries][zones], as well as for each of your tax categories. If your stores
have more complicated tax requirements, your tax rates can perform more complex
functions:

- You can create tax rates that calculate using sales tax (U.S.-style taxes) or
  value-added taxes (VAT, or E.U.-style taxes).
- You can show or hide tax rates in customer invoices.
- You can create tax rates that are valid from a specific date.
- You can change the **Base Calculator** to a custom tax calculator.[^1]

[^1]: Talk to your developers if you need another tax calculator. By default,
  Solidus only provides a base calculator, which is acceptable for calculating
  taxes in most ecommerce stores. 

[zones]: zones.md 
