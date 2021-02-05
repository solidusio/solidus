# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
