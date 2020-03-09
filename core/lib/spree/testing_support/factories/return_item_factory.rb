# frozen_string_literal: true

require 'spree/testing_support/factories/inventory_unit_factory'
require 'spree/testing_support/factories/return_reason_factory'
require 'spree/testing_support/factories/return_authorization_factory'

FactoryBot.define do
  factory :return_item, class: 'Spree::ReturnItem' do
    association(:inventory_unit, factory: :inventory_unit, state: :shipped)
    association(:return_reason, factory: :return_reason)
    return_authorization do |_return_item|
      build(:return_authorization, order: inventory_unit.order)
    end

    factory :exchange_return_item do
      after(:build) do |return_item|
        # set track_inventory to false to ensure it passes the in_stock check
        return_item.inventory_unit.variant.update_column(:track_inventory, false)
        return_item.exchange_variant = return_item.inventory_unit.variant
      end
    end
  end
end
