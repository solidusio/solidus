# Custom tax calculators

*Note that Solidus supports value-added tax (VAT) and sales tax out of the
box. You would only need to create a custom tax calculator in extraordinary
circumstances.*

By default, Solidus uses a simple tax rate calculator. It multiples against an
item price and adjusts for any promotions to determine tax. However, this tax
calculator can be changed if you need to develop a more specialized tax
calculator for your application.
 
But in most cases, you should be able to use the `Spree::Calculator::DefaultTax`
calculator. It is suitable for both sales tax and VAT scenarios.

If you need to change the default tax calculation behavior, see the [default tax
calculator specs][default-tax-calculator-spec] or [its
implementation][default-tax-calculator].

[default-tax-calculator-spec]: https://github.com/solidusio/solidus/blob/master/core/spec/models/spree/calculator/default_tax_spec.rb
[default-tax-calculator]: https://github.com/solidusio/solidus/blob/master/core/app/models/spree/calculator/default_tax.rb

<!-- TODO:
  This article is a stub, but it may be useful to provide a simple example, or
  at least a checklist for any developer needing to create a custom tax
  calculator.

  It may also make sense to move this article to a [Calculators](/calculators)
  guide in the future.
-->
