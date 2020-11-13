# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
