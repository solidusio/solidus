# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :shipping_rate, class: 'Spree::ShippingRate' do
    shipping_method
    shipment
  end
end
