# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/order_factory'
  require 'spree/testing_support/factories/promotion_factory'
end

FactoryBot.define do
  factory :order_promotion, class: 'Spree::OrderPromotion' do
    association :order
    association :promotion
  end
end

