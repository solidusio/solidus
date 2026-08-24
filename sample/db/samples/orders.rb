# frozen_string_literal: true

Spree::Sample.load_sample("addresses")
Spree::Sample.load_sample("stores")

payment_method = Spree::PaymentMethod::Check.first!
store = Spree::Store.first!

orders = []

orders << Spree::Order.find_or_create_by!(number: "R123456789") do |order|
  order.email = "spree@example.com"
  order.item_total = 150.95
  order.adjustment_total = 150.95
  order.total = 301.90
  order.ship_address = Spree::Address.first
  order.bill_address = Spree::Address.last
end

orders << Spree::Order.find_or_create_by!(number: "R987654321") do |order|
  order.email = "spree@example.com"
  order.item_total = 15.95
  order.adjustment_total = 15.95
  order.total = 31.90
  order.ship_address = Spree::Address.first
  order.bill_address = Spree::Address.last
end

orders[0].line_items.find_or_create_by!(
  variant: Spree::Product.find_by!(name: "Solidus Water Bottle").master
) do |line_item|
  line_item.quantity = 1
  line_item.price = 15.99
end

orders[1].line_items.find_or_create_by!(
  variant: Spree::Product.find_by!(name: "Solidus cap").master
) do |line_item|
  line_item.quantity = 1
  line_item.price = 22.99
end

orders.each do |order|
  order.payments.find_or_create_by!(payment_method:)
  order.update(store:)

  unless order.completed?
    order.next! until order.can_complete?
    order.complete!
  end
end
