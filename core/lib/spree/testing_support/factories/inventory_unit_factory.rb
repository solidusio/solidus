# frozen_string_literal: true

FactoryBot.define do
  factory :inventory_unit, class: "Spree::InventoryUnit" do
    transient do
      order { nil }
      stock_location { nil }
    end

    association :variant, strategy: :create
    line_item do
      if order
        build(:line_item, variant:, order:)
      else
        build(:line_item, variant:)
      end
    end
    state { "on_hand" }
    shipment do
      if stock_location
        build(:shipment, state: "pending", order: line_item.order, stock_location:)
      else
        build(:shipment, state: "pending", order: line_item.order)
      end
    end
    # return_authorization
  end
end
