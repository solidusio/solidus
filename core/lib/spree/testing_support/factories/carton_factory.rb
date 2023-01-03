# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/shipment_factory'
  require 'spree/testing_support/factories/inventory_unit_factory'
end

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

