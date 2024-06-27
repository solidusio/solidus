# frozen_string_literal: true

FactoryBot.define do
  factory :solidus_promotion_code, class: "SolidusPromotions::PromotionCode" do
    association :promotion, factory: :solidus_promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
