# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      def initialize(order, inventory_units: nil)
        @context = {order:, inventory_units:}
        @order = order

        Middleware::InventoryUnit.new.call(@context)
        Middleware::InventoryUnitGroup.new.call(@context)
        Middleware::StockLocation.new.call(@context)
        Middleware::Desired.new.call(@context)
        Middleware::Availability.new.call(@context)
      end

      def shipments
        @shipments ||= begin
                         Middleware::Allocate.new.call(@context)
                         Middleware::Package.new.call(@context)
                         Middleware::Shipment.new.call(@context)

                         shipments = @context[:shipments]

                         # Make sure we don't add the proposed shipments to the order
                         @order.shipments = @order.shipments - shipments

                         shipments
                       end
      end
    end
  end
end
