# frozen_string_literal: true

FactoryBot.define do
  factory :order_promotion, class: "Spree::OrderPromotion" do
    association :order
    association :promotion
  end
end
