# frozen_string_literal: true

module Spree
  module Stock
    # This class is responsible for coordinating the building of shipments for
    # an order. It takes in an order and an optional list of stock locations and
    # inventory units, then builds shipments based on the available stock and
    # the order's requirements for fulfillment.
    class Coordinator
      attr_reader :order

      # @api private
      attr_reader :inventory_units, :splitters, :stock_locations

      # @param order [Spree::Order] the order to build shipments for
      # @param inventory_units [Array<Spree::InventoryUnit>] the inventory units to build shipments for
      # @param stock_locations [Array<Spree::StockLocation>] the stock locations to build shipments from
      # @param config [Hash] the configuration options for the coordinator
      # @option config [Class] :package_builder_class
      # @option config [Class] :shipment_builder_class
      # @option config [Class] :inventory_unit_builder_class
      # @option config [Class] :allocator_class
      # @option config [Class] :estimator_class
      # @option config [Array<Class>] :splitters
      def initialize(order, inventory_units: nil, stock_locations: Spree::StockLocation.all, config: {})
        @order = order
        @inventory_units = inventory_units
        @stock_locations = stock_locations

        @inventory_unit_builder_class = config.fetch(:inventory_unit_builder_class, Spree::Config.stock.inventory_unit_builder_class)
        @allocator_class = config.fetch(:allocator_class, Spree::Config.stock.allocator_class)
        @package_builder_class = config.fetch(:package_builder_class, Spree::Config.stock.package_builder_class)
        @shipment_builder_class = config.fetch(:shipment_builder_class, Spree::Config.stock.shipment_builder_class)
        @estimator_class = config.fetch(:estimator_class, Spree::Config.stock.estimator_class)

        @splitters = config.fetch(:splitters, Spree::Config.environment.stock_splitters)
      end

      # Builds packages, then splits them, and converts them into shipments. The
      # resulting shipments are not added to the order.
      #
      # @return [Array<Spree::Shipment>] the shipments built for the order
      def shipments
        @shipments ||= begin
          packages = build_packages
          packages = split_packages(packages)
          shipments = build_shipments(packages)

          # Make sure we don't add the proposed shipments to the order
          order.shipments = order.shipments - shipments

          shipments
        end
      end

      private

      def build_shipments(packages)
        @shipment_builder_class.new(
          packages:,
          estimator_class: @estimator_class
        ).call
      end

      def build_packages
        @inventory_units ||= @inventory_unit_builder_class.new(order).units

        @package_builder_class.new(
          inventory_units: @inventory_units,
          stock_locations: @stock_locations,
          allocator_class: @allocator_class
        ).call
      end

      def split_packages(initial_packages)
        initial_packages.flat_map do |initial_package|
          stock_location = initial_package.stock_location
          Spree::Stock::SplitterChain.new(stock_location, @splitters).split([initial_package])
        end
      end
    end
  end
end
