# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/shipping_method_factory'
  require 'spree/testing_support/factories/shipment_factory'
end

FactoryBot.define do
  factory :shipping_rate, class: 'Spree::ShippingRate' do
    shipping_method
    shipment
  end
end

