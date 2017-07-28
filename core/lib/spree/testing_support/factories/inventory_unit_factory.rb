require 'spree/testing_support/factories/line_item_factory'
require 'spree/testing_support/factories/variant_factory'
require 'spree/testing_support/factories/order_factory'
require 'spree/testing_support/factories/shipment_factory'

FactoryGirl.define do
  factory :inventory_unit, class: Spree::InventoryUnit do
    variant
    order
    line_item { build(:line_item, order: order, variant: variant) }
    state 'on_hand'
    shipment { build(:shipment, state: 'pending', order: order) }
    # return_authorization
  end
end
