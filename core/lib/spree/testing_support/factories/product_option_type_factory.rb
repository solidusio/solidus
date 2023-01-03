# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/product_factory'
  require 'spree/testing_support/factories/option_type_factory'
end

FactoryBot.define do
  factory :product_option_type, class: 'Spree::ProductOptionType' do
    product
    option_type
  end
end

