# frozen_string_literal: true

FactoryBot.define do
  factory :solidus_order_promotion, class: "SolidusPromotions::OrderPromotion" do
    association :order, factory: :order
    association :promotion, factory: :solidus_promotion
  end
end
