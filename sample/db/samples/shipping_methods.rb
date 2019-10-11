# frozen_string_literal: true

begin
north_america = Solidus::Zone.find_by!(name: "North America")
rescue ActiveRecord::RecordNotFound
  puts "Couldn't find 'North America' zone. Did you run `rake db:seed` first?"
  puts "That task will set up the countries, states and zones required for Solidus."
  exit
end

tax_category = Solidus::TaxCategory.find_by!(name: "Default")
europe_vat = Solidus::Zone.find_by!(name: "EU_VAT")
shipping_category = Solidus::ShippingCategory.find_or_create_by!(name: 'Default')

Solidus::ShippingMethod.create!([
  {
    name: "UPS Ground (USD)",
    zones: [north_america],
    calculator: Solidus::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  },
  {
    name: "UPS Two Day (USD)",
    zones: [north_america],
    calculator: Solidus::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  },
  {
    name: "UPS One Day (USD)",
    zones: [north_america],
    calculator: Solidus::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  },
  {
    name: "UPS Ground (EU)",
    zones: [europe_vat],
    calculator: Solidus::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  },
  {
    name: "UPS Ground (EUR)",
    zones: [europe_vat],
    calculator: Solidus::Calculator::Shipping::FlatRate.create!,
    tax_category: tax_category,
    shipping_categories: [shipping_category]
  }
])

{
  "UPS Ground (USD)" => [5, "USD"],
  "UPS Ground (EU)" => [5, "USD"],
  "UPS One Day (USD)" => [15, "USD"],
  "UPS Two Day (USD)" => [10, "USD"],
  "UPS Ground (EUR)" => [8, "EUR"]
}.each do |shipping_method_name, (price, currency)|
  shipping_method = Solidus::ShippingMethod.find_by!(name: shipping_method_name)
  shipping_method.calculator.preferences = {
    amount: price,
    currency: currency
  }
  shipping_method.calculator.save!
  shipping_method.save!
end
