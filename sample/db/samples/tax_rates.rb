# frozen_string_literal: true

north_america = Solidus::Zone.find_by!(name: "North America")
clothing = Solidus::TaxCategory.find_by!(name: "Default")
tax_rate = Solidus::TaxRate.create(
  name: "North America",
  zone: north_america,
  amount: 0.05
)
tax_rate.calculator = Solidus::Calculator::DefaultTax.create!
tax_rate.save!
Solidus::TaxRateTaxCategory.create!(
  tax_rate: tax_rate,
  tax_category: clothing
)
