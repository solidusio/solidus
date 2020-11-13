# frozen_string_literal: true

require 'spree/testing_support'
Spree::TestingSupport.deprecate_cherry_picking_factory_bot_files

FactoryBot.define do
  factory :customer_return, class: 'Spree::CustomerReturn' do
    association(:stock_location, factory: :stock_location)

    transient do
      line_items_count { 1 }
      return_items_count { line_items_count }
      shipped_order { create :shipped_order, line_items_count: line_items_count }
      return_authorization { create :return_authorization, order: shipped_order }
    end

    before(:create) do |customer_return, evaluator|
      evaluator.shipped_order.inventory_units.take(evaluator.return_items_count).each do |inventory_unit|
        customer_return.return_items << build(:return_item, inventory_unit: inventory_unit, return_authorization: evaluator.return_authorization)
      end
    end

    factory :customer_return_with_accepted_items do
      after(:create) do |customer_return|
        customer_return.return_items.each(&:accept!)
      end
    end
  end

  # for the case when you want to supply existing return items instead of generating some
  factory :customer_return_without_return_items, class: 'Spree::CustomerReturn' do
    association(:stock_location, factory: :stock_location)
  end
end
