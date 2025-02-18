# frozen_string_literal: true

FactoryBot.define do
  factory :shipment, class: "Spree::Shipment" do
    tracking { "U10000" }
    cost { 100.00 }
    state { "pending" }
    order
    stock_location

    transient do
      shipping_method { nil }
    end

    after(:create) do |shipment, evaluator|
      shipping_method = evaluator.shipping_method || create(:shipping_method, cost: evaluator.cost)
      shipment.shipping_rates.create!(
        shipping_method:,
        cost: evaluator.cost,
        selected: true
      )

      shipment.order.line_items.each do |line_item|
        line_item.quantity.times do
          shipment.inventory_units.create!(
            variant_id: line_item.variant_id,
            line_item_id: line_item.id
          )
        end
      end
    end
  end
end
