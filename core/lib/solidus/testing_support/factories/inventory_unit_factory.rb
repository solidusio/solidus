FactoryGirl.define do
  factory :inventory_unit, class: Solidus::InventoryUnit do
    variant
    order
    line_item { build(:line_item, order: order, variant: variant) }
    state 'on_hand'
    shipment { build(:shipment, state: 'pending', order: order) }
    # return_authorization
  end
end
