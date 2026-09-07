# frozen_string_literal: true

north_america = Spree::Zone.find_by!(name: "North America")
clothing = Spree::TaxCategory.find_by!(name: "Default")
tax_rate = Spree::TaxRate.find_or_initialize_by(name: "North America", zone: north_america)

if tax_rate.new_record?
  tax_rate.amount = 0.05
  tax_rate.calculator = Spree::Calculator::DefaultTax.create!
  tax_rate.save!
end

Spree::TaxRateTaxCategory.find_or_create_by!(
  tax_rate:,
  tax_category: clothing
)
