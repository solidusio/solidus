# frozen_string_literal: true

begin
  north_america = Spree::Zone.find_by!(name: "North America")
rescue ActiveRecord::RecordNotFound
  puts <<~TEXT
    Couldn't find 'North America' zone. Did you run `rails db:seed` first?

    That task will set up the countries, states and zones required for your store.
  TEXT
  exit
end

clothing = Spree::TaxCategory.find_by!(name: "Default")
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
