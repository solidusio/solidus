# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/shipment_factory'
end

FactoryBot.define do
  factory :shipment_discount, class: 'Spree::ShipmentDiscount' do
    amount { BigDecimal("-4.00") }
    shipment
    promotion_action { Spree::Promotion::Actions::CreateAdjustment.new }
    label { "10% off" }
  end
end
