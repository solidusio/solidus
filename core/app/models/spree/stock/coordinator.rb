# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      attr_reader :order

      # @api private
      attr_reader :inventory_units, :splitters, :stock_locations

      def initialize(
        order,
        inventory_units: nil,
        inventory_unit_builder_class: Spree::Config.stock.inventory_unit_builder_class,
        splitters: Spree::Config.environment.stock_splitters,
        allocator_class: Spree::Config.stock.allocator_class,
        estimator_class: Spree::Config.stock.estimator_class,
        package_builder_class: Spree::Config.stock.package_builder_class,
        shipment_builder_class: Spree::Config.stock.shipment_builder_class,
        stock_locations: Spree::StockLocation.all
      )
        @order = order
        @inventory_units = inventory_units
        @stock_locations = stock_locations

        @inventory_unit_builder_class = inventory_unit_builder_class
        @allocator_class = allocator_class
        @package_builder_class = package_builder_class
        @shipment_builder_class = shipment_builder_class
        @estimator_class = estimator_class

        @splitters = splitters
      end

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
