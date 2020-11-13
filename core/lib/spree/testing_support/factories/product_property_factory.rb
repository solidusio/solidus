# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :product_property, class: 'Spree::ProductProperty' do
    product
    property
  end
end
