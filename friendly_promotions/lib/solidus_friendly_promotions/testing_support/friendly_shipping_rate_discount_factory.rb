# frozen_string_literal: true

FactoryBot.define do
  factory :friendly_shipping_rate_discount, class: 'SolidusFriendlyPromotions::ShippingRateDiscount' do
    amount { BigDecimal("-4.00") }
    shipping_rate
    promotion_action { SolidusFriendlyPromotions::Actions::AdjustShipment.new }
    label { "10% off" }
  end
end
