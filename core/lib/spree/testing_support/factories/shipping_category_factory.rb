# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :shipping_category, class: 'Spree::ShippingCategory' do
    sequence(:name) { |n| "ShippingCategory ##{n}" }
  end
end
