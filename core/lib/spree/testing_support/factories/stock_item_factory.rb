# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

FactoryBot.define do
  factory :stock_item, class: 'Spree::StockItem' do
    backorderable { true }
    association :stock_location, factory: :stock_location_without_variant_propagation
    variant

    after(:create) { |object| object.adjust_count_on_hand(10) }
  end
end
