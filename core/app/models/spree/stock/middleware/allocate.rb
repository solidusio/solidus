module Spree
  module Stock
    module Middleware
      class Allocate
        def call(context)
          allocator = Spree::Config.stock.allocator_class.new(context.availability)
          on_hand_packages, backordered_packages, leftover = allocator.allocate_inventory(context.desired)

          raise Spree::Order::InsufficientStock.new(items: leftover.quantities) unless leftover.empty?

          context.on_hand_packages = on_hand_packages
          context.backordered_packages = backordered_packages

          yield context
        end
      end
    end
  end
end
