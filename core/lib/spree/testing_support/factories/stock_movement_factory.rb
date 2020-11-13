# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

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
