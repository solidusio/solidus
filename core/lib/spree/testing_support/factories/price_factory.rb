# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/variant_factory'
end

FactoryBot.define do
  factory :price, class: 'Spree::Price' do
    variant
    amount { 19.99 }
    currency { 'USD' }
  end
end

