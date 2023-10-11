# frozen_string_literal: true

FactoryBot.define do
  factory :friendly_order_promotion, class: "SolidusFriendlyPromotions::OrderPromotion" do
    association :order, factory: :order
    association :promotion, factory: :friendly_promotion
  end
end
