require 'spree/testing_support/factories/stock_location_factory'
require 'spree/testing_support/factories/variant_factory'

FactoryGirl.define do
  factory :stock_item, class: Spree::StockItem do
    backorderable true
    association :stock_location, factory: :stock_location_without_variant_propagation
    variant

    after(:create) { |object| object.adjust_count_on_hand(10) }
  end
end
