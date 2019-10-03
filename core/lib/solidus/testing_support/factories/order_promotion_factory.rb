# frozen_string_literal: true

require 'solidus/testing_support/factories/order_factory'
require 'solidus/testing_support/factories/promotion_factory'

FactoryBot.define do
  factory :order_promotion, class: 'Solidus::OrderPromotion' do
    association :order
    association :promotion
  end
end
