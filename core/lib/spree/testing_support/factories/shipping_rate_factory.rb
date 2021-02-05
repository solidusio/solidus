# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :shipping_rate, class: 'Spree::ShippingRate' do
    shipping_method
    shipment
  end
end
