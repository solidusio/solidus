# frozen_string_literal: true

Solidus::Sample.load_sample("variants")

country =  Solidus::Country.find_by(iso: 'US')
location = Solidus::StockLocation.first_or_create! name: 'default', address1: 'Example Street', city: 'City', zipcode: '12345', country: country, state: country.states.first
location.active = true
location.save!

Solidus::Variant.all.each do |variant|
  variant.stock_items.each do |stock_item|
    Solidus::StockMovement.create(quantity: 10, stock_item: stock_item)
  end
end
