# frozen_string_literal: true

FactoryBot.define do
  factory :solidus_shipping_rate_discount, class: "SolidusPromotions::ShippingRateDiscount" do
    amount { BigDecimal("-4.00") }
    shipping_rate
    benefit do
      promotion = create(:solidus_promotion, name: "10% off shipping!", customer_label: "10% off")
      ten_percent = SolidusPromotions::Calculators::Percent.new(preferred_percent: 10)
      SolidusPromotions::Benefits::AdjustShipment.create!(promotion: promotion, calculator: ten_percent)
    end
    label { "10% off" }
  end
end
