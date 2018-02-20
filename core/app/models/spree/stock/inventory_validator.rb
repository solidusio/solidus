# frozen_string_literal: true

module Spree
  module Stock
    class InventoryValidator < ActiveModel::Validator
      def validate(line_item)
        if line_item.inventory_units.count != line_item.quantity
          line_item.errors[:inventory] << I18n.t(
            'spree.inventory_not_available',
            item: line_item.variant.name
          )
        end
      end
    end
  end
end
