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
        estimator_class: Spree::Config.stock.estimator_class,
        stock_locations: Spree::StockLocation.all
      )
        @order = order
        @inventory_units = inventory_units
        @stock_locations = stock_locations

        @inventory_unit_builder_class = inventory_unit_builder_class

        @estimator = estimator_class.new

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
        # Turn the Stock::Packages into a Shipment with rates
        packages.map do |package|
          shipment = package.shipment = package.to_shipment
          shipment.shipping_rates = @estimator.shipping_rates(package)
          shipment
        end
      end

      def build_packages
        @inventory_units ||= @inventory_unit_builder_class.new(order).units

        Spree::Config.stock.package_builder_class.new(
          inventory_units: @inventory_units,
          stock_locations: @stock_locations
        ).call
      end

      def split_packages(initial_packages)
        initial_packages.flat_map do |initial_package|
          stock_location = initial_package.stock_location
          Spree::Stock::SplitterChain.new(stock_location, @splitters).split([initial_package])
        end
      end

      def get_units(quantities)
        # Change our raw quantities back into inventory units
        quantities.flat_map do |variant, quantity|
          @inventory_units_by_variant[variant].shift(quantity)
        end
      end
    end
  end
end

