# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :order_promotion, class: 'Spree::OrderPromotion' do
    association :order
    association :promotion
  end
end
