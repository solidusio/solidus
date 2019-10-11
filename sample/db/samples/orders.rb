# frozen_string_literal: true

Solidus::Sample.load_sample("addresses")
Solidus::Sample.load_sample("stores")

payment_method = Solidus::PaymentMethod::Check.first!
store = Solidus::Store.first!

orders = []
orders << Solidus::Order.create!(
  number: "R123456789",
  email: "spree@example.com",
  item_total: 150.95,
  adjustment_total: 150.95,
  total: 301.90,
  shipping_address: Solidus::Address.first,
  billing_address: Solidus::Address.last
)

orders << Solidus::Order.create!(
  number: "R987654321",
  email: "spree@example.com",
  item_total: 15.95,
  adjustment_total: 15.95,
  total: 31.90,
  shipping_address: Solidus::Address.first,
  billing_address: Solidus::Address.last
)

orders[0].line_items.create!(
  variant: Solidus::Product.find_by!(name: "Solidus Tote").master,
  quantity: 1,
  price: 15.99
)

orders[1].line_items.create!(
  variant: Solidus::Product.find_by!(name: "Solidus Snapback Cap").master,
  quantity: 1,
  price: 22.99
)

orders.each do |order|
  order.payments.create!(payment_method: payment_method)
  order.update(store: store)

  order.next! while !order.can_complete?
  order.complete!
end
