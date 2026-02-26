# frozen_string_literal: true

FactoryBot.define do
  factory :product_property, class: "Spree::ProductProperty" do
    product
    property
  end
end
