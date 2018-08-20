# frozen_string_literal: true

require 'spree/testing_support/factories/line_item_factory'
require 'spree/testing_support/factories/variant_factory'
require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/shipment_factory'

FactoryBot.define do
  factory :inventory_unit, class: 'Spree::InventoryUnit' do
    transient do
      order { nil }
    end

    variant
    line_item do
      if order
        build(:line_item, variant: variant, order: order)
      else
        build(:line_item, variant: variant)
      end
    end
    state { 'on_hand' }
    shipment { build(:shipment, state: 'pending', order: line_item.order) }
    # return_authorization
  end
end
