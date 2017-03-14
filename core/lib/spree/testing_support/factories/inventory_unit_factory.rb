require 'spree/testing_support/factories/line_item_factory'
require 'spree/testing_support/factories/variant_factory'
require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/shipment_factory'

FactoryGirl.define do
  factory :inventory_unit, class: Spree::InventoryUnit do
    variant
    line_item { build(:line_item, variant: variant) }
    state 'on_hand'
    shipment { build(:shipment, state: 'pending', order: line_item.order) }
    # return_authorization
  end
end
