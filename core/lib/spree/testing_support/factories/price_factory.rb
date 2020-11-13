# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :price, class: 'Spree::Price' do
    variant
    amount { 19.99 }
    currency { 'USD' }
  end
end
