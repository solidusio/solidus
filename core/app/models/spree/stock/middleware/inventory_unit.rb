module Spree
  module Stock
    module Middleware
      class InventoryUnit
        def call(context)
          order = context[:order]

          context[:inventory_units] = context[:inventory_units] ||
            Spree::Config.stock.inventory_unit_builder_class.new(order).units
        end
      end
    end
  end
end

