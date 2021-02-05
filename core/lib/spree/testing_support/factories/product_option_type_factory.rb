# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :product_option_type, class: 'Spree::ProductOptionType' do
    product
    option_type
  end
end
