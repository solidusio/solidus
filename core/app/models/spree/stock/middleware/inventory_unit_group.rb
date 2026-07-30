module Spree
  module Stock
    module Middleware
      class InventoryUnitGroup
        def call(context)
          context.inventory_unit_groups = context.inventory_units.group_by(&:variant)

          yield context
        end
      end
    end
  end
end
