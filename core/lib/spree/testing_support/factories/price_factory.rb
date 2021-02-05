# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :price, class: 'Spree::Price' do
    variant
    amount { 19.99 }
    currency { 'USD' }
  end
end
