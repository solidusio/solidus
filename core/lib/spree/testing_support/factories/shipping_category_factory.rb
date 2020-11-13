# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :shipping_category, class: 'Spree::ShippingCategory' do
    sequence(:name) { |n| "ShippingCategory ##{n}" }
  end
end
