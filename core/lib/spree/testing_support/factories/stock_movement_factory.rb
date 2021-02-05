# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :stock_movement, class: 'Spree::StockMovement' do
    quantity { 1 }
    action { 'sold' }
    stock_item
  end

  trait :received do
    action { 'received' }
  end
end
