# frozen_string_literal: true

FactoryBot.define do
  factory :carton, class: "Spree::Carton" do
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
            stock_location:,
            shipping_method:
          )
        )
      ]
    end
  end
end
