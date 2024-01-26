# frozen_string_literal: true

FactoryBot.define do
  factory :promotion_code, class: 'Spree::PromotionCode' do
    promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
