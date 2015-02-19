module Spree
  module Stock
    class InventoryValidator < ActiveModel::Validator
      def validate(line_item)
        if line_item.inventory_units.count != line_item.quantity
          line_item.errors[:inventory] << Spree.t(
            :inventory_not_available,
            item: line_item.variant.name
          )
        end
      end
    end
  end
end
