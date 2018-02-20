# frozen_string_literal: true

require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/promotion_factory'

FactoryBot.define do
  factory :order_promotion, class: 'Spree::OrderPromotion' do
    association :order
    association :promotion
  end
end
