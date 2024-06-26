# frozen_string_literal: true

FactoryBot.define do
  factory :friendly_promotion_code, class: "SolidusPromotions::PromotionCode" do
    association :promotion, factory: :friendly_promotion
    sequence(:value) { |i| "code#{i}" }
  end
end
