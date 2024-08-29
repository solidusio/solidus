# frozen_string_literal: true

Spree::Sample.load_sample("variants")

country = Spree::Country.find_by(iso: "US")
location = Spree::StockLocation.first_or_create! name: "default", address1: "Example Street", city: "City", zipcode: "12345", country:, state: country.states.first
location.active = true
location.save!

Spree::Variant.all.find_each do |variant|
  variant.stock_items.each do |stock_item|
    Spree::StockMovement.create(quantity: 10, stock_item:)
  end
end
