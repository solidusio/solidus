# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :order_promotion, class: 'Spree::OrderPromotion' do
    association :order
    association :promotion
  end
end
