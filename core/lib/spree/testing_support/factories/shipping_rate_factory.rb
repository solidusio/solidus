# frozen_string_literal: true

FactoryBot.define do
  factory :shipping_rate, class: "Spree::ShippingRate" do
    shipping_method
    shipment
  end
end
