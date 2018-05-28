# Tax calculator

Solidus comes with a tax calculator that is used to calculate both sales tax
(United States-style taxes) and value-added tax (VAT):
[`Spree::Calculator::DefaultTax`][default-tax-calculator]. Typically, this
calculator should be the only tax calculator required by your store.

Using this calculator, all tax rates are represented as a decimal. So, a tax
rate of 5% should be represented as `0.05`.

Taxes can apply to line items, shipments, or an entire order.

The tax calculator uses its calculable – a `Spree::TaxRate` – to calculate tax
totals.

For more comprehensive documentation about taxes in Solidus, see the
[Taxation][taxation] documentation.

If your store's tax requirements are more complicated, you may want to create a
[custom tax calculator][custom-tax-calculator] or use an extension like
[`solidus_tax_cloud`][solidus-tax-cloud].

[custom-tax-calculator]: ../taxation/custom-tax-calculators.html
[default-tax-calculator]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/default_tax.rb
[solidus-tax-cloud]: https://github.com/solidusio-contrib/solidus_tax_cloud
[taxation]: ../taxation/overview.html

