# frozen_string_literal: true

north_america = Spree::Zone.where(name: "North America").first
clothing = Spree::TaxCategory.where(name: "Default").first
tax_rate = Spree::TaxRate.create(
  name: "North America",
  zone: north_america,
  amount: 0.05
)
tax_rate.calculator = Spree::Calculator::DefaultTax.create!
tax_rate.save!
Spree::TaxRateTaxCategory.create!(
  tax_rate: tax_rate,
  tax_category: clothing
)
