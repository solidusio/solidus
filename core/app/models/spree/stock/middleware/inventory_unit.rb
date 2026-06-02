module Spree
  module Stock
    module Middleware
      class InventoryUnit
        def call(context)
          context.inventory_units ||=
            Spree::Config.stock.inventory_unit_builder_class.new(context.order).units

          yield context
        end
      end
    end
  end
end
