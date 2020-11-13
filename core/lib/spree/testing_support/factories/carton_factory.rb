# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :carton, class: 'Spree::Carton' do
    address
    stock_location
    shipping_method
    shipped_at { Time.current }
    inventory_units do
      [
        build(
          :inventory_unit,
          # ensure the shipment uses the same stock location as the carton
          shipment: build(
            :shipment,
            stock_location: stock_location,
            shipping_method: shipping_method
          )
        )
      ]
    end
  end
end
