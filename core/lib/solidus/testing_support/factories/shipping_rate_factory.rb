# frozen_string_literal: true

require 'solidus/testing_support/factories/shipping_method_factory'
require 'solidus/testing_support/factories/shipment_factory'

FactoryBot.define do
  factory :shipping_rate, class: 'Solidus::ShippingRate' do
    shipping_method
    shipment
  end
end
