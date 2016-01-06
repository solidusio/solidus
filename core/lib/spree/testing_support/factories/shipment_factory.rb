require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/stock_location_factory'
require 'spree/testing_support/factories/shipping_method_factory'
require 'spree/testing_support/factories/stock_location_factory'

FactoryGirl.define do
  factory :shipment, class: Spree::Shipment do
    tracking 'U10000'
    cost 100.00
    state 'pending'
    order
    stock_location

    transient do
      shipping_method nil
    end

    after(:create) do |shipment, evalulator|
      shipping_method = evalulator.shipping_method || create(:shipping_method, cost: evalulator.cost)
      shipment.add_shipping_method(shipping_method, true)

      shipment.order.line_items.each do |line_item|
        line_item.quantity.times do
          shipment.inventory_units.create!(
            order_id: shipment.order_id,
            variant_id: line_item.variant_id,
            line_item_id: line_item.id
          )
        end
      end
    end
  end
end
