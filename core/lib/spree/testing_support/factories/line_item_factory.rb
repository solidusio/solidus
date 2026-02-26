# frozen_string_literal: true

FactoryBot.define do
  factory :line_item, class: "Spree::LineItem" do
    quantity { 1 }
    price { BigDecimal("10.00") }
    order
    transient do
      product { nil }
    end
    variant do
      (product || create(:product)).master
    end
  end
end
