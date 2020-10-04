# frozen_string_literal: true

require 'spree/testing_support/factories/shipping_method_factory'
require 'spree/testing_support/factories/shipment_factory'

FactoryBot.define do
  factory :shipping_rate, class: 'Spree::ShippingRate' do
    shipping_method
    shipment
  end
end
