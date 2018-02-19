# frozen_string_literal: true

require 'spree/testing_support/sequences'
require 'spree/testing_support/factories/promotion_factory'

FactoryBot.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
