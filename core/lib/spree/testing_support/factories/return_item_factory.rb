# frozen_string_literal: true

FactoryBot.define do
  factory :return_item, class: 'Spree::ReturnItem' do
    inventory_unit do
      # When a return authorization is given, the inventory unit must belong
      # to the same order.
      if __override_names__.include?(:return_authorization) && return_authorization&.order
        association(:inventory_unit, state: :shipped, order: return_authorization.order)
      else
        association(:inventory_unit, state: :shipped)
      end
    end
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
