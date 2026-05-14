# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      def initialize(order, inventory_units: nil)
        @context = {order:, inventory_units:}
        @order = order

        Middleware::InventoryUnit.new.call(@context)
        Middleware::InventoryUnitGroup.new.call(@context)

        @splitters = Spree::Config.environment.stock_splitters

        Middleware::StockLocation.new.call(@context)
        Middleware::Desired.new.call(@context)
        Middleware::Availability.new.call(@context)
      end

      def shipments
        @shipments ||= begin
                         Middleware::Allocate.new.call(@context)

                         @packages = build_packages
                         shipments = build_shipments

                         # Make sure we don't add the proposed shipments to the order
                         @order.shipments = @order.shipments - shipments

                         shipments
                       end
      end

      private

      def build_shipments
        @packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = Spree::Config.stock.estimator_class.new.shipping_rates(package)
          shipment
        end
      end

      def build_packages
        packages = @context[:stock_locations].map do |stock_location|
          on_hand = @context[:on_hand_packages][stock_location.id] || Spree::StockQuantities.new
          backordered = @context[:backordered_packages][stock_location.id] || Spree::StockQuantities.new

          next if on_hand.empty? && backordered.empty?

          package = Spree::Stock::Package.new(stock_location)
          package.add_multiple(get_units(on_hand), :on_hand)
          package.add_multiple(get_units(backordered), :backordered)

          package
        end.compact

        split_packages(packages)
      end

      def split_packages(initial_packages)
        initial_packages.flat_map do |initial_package|
          stock_location = initial_package.stock_location
          Spree::Stock::SplitterChain.new(stock_location, @splitters).split([initial_package])
        end
      end

      def get_units(quantities)
        quantities.flat_map do |variant, quantity|
          @context[:inventory_unit_groups][variant].shift(quantity)
        end
      end
    end
  end
end
