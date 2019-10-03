# frozen_string_literal: true

require 'solidus/testing_support/sequences'
require 'solidus/testing_support/factories/promotion_factory'

FactoryBot.define do
  factory :promotion_code, class: 'Solidus::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
