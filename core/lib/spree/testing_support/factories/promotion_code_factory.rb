# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/sequences'
  require 'spree/testing_support/factories/promotion_factory'
end

FactoryBot.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end

