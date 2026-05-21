# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      def initialize(order, inventory_units: nil)
        @order = order
        @context = Context.new(order: order, inventory_units: inventory_units)
      end

      def shipments
        @shipments ||= begin
                         Spree::MiddlewareRunner.call(Spree::Config.stock.coordinator_middlewares, @context)

                         shipments = @context.shipments

                         # Make sure we don't add the proposed shipments to the order
                         @order.shipments = @order.shipments - shipments

                         shipments
                       end
      end
    end
  end
end
