# frozen_string_literal: true

require 'spree/testing_support/factory_bot'
Spree::TestingSupport::FactoryBot.when_cherry_picked do
  Spree::TestingSupport::FactoryBot.deprecate_cherry_picking

  require 'spree/testing_support/factories/line_item_factory'
  require 'spree/testing_support/factories/variant_factory'
  require 'spree/testing_support/factories/order_factory'
  require 'spree/testing_support/factories/shipment_factory'
end

FactoryBot.define do
  factory :inventory_unit, class: 'Spree::InventoryUnit' do
    transient do
      order { nil }
      stock_location { nil }
    end

    association :variant, strategy: :create
    line_item do
      if order
        build(:line_item, variant: variant, order: order)
      else
        build(:line_item, variant: variant)
      end
    end
    state { 'on_hand' }
    shipment do
      if stock_location
        build(:shipment, state: 'pending', order: line_item.order, stock_location: stock_location)
      else
        build(:shipment, state: 'pending', order: line_item.order)
      end
    end
    # return_authorization
  end
end

