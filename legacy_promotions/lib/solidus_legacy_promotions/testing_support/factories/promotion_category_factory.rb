# frozen_string_literal: true

FactoryBot.define do
  factory :promotion_category, class: 'Spree::PromotionCategory' do
    name { 'Promotion Category' }
  end
end
