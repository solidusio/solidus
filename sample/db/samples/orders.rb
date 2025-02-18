# frozen_string_literal: true

Spree::Sample.load_sample("addresses")
Spree::Sample.load_sample("stores")

payment_method = Spree::PaymentMethod::Check.first!
store = Spree::Store.first!

orders = []

orders << Spree::Order.create!(
  number: "R123456789",
  email: "spree@example.com",
  item_total: 150.95,
  adjustment_total: 150.95,
  total: 301.90,
  ship_address: Spree::Address.first,
  bill_address: Spree::Address.last
)

orders << Spree::Order.create!(
  number: "R987654321",
  email: "spree@example.com",
  item_total: 15.95,
  adjustment_total: 15.95,
  total: 31.90,
  ship_address: Spree::Address.first,
  bill_address: Spree::Address.last
)

orders[0].line_items.create!(
  variant: Spree::Product.find_by!(name: "Solidus Water Bottle").master,
  quantity: 1,
  price: 15.99
)

orders[1].line_items.create!(
  variant: Spree::Product.find_by!(name: "Solidus cap").master,
  quantity: 1,
  price: 22.99
)

orders.each do |order|
  order.payments.create!(payment_method:)
  order.update(store:)

  order.next! until order.can_complete?
  order.complete!
end
