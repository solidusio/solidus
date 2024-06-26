# frozen_string_literal: true

FactoryBot.define do
  factory :friendly_promotion_category, class: "SolidusPromotions::PromotionCategory" do
    name { "Promotion Category" }
  end
end
