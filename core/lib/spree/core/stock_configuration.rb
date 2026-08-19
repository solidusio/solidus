# frozen_string_literal: true

module Spree
  module Core
    class StockConfiguration < Spree::Preferences::Configuration
      class_name_attribute :coordinator_class, default: "::Spree::Stock::SimpleCoordinator"
      class_name_attribute :estimator_class, default: "::Spree::Stock::Estimator"
      class_name_attribute :location_filter_class, default: "::Spree::Stock::LocationFilter::Active"
      class_name_attribute :location_sorter_class, default: "::Spree::Stock::LocationSorter::Unsorted"
      class_name_attribute :allocator_class, default: "::Spree::Stock::Allocator::OnHandFirst"
      class_name_attribute :inventory_unit_builder_class, default: "::Spree::Stock::InventoryUnitBuilder"
      class_name_attribute :availability_validator_class, default: "::Spree::Stock::AvailabilityValidator"
      class_name_attribute :inventory_validator_class, default: "::Spree::Stock::InventoryValidator"
      class_name_attribute :quantifier_class, default: "::Spree::Stock::Quantifier"

      # Builds an instance of the configured {#coordinator_class} for the given
      # order, passing in the filtered and sorted stock locations when the
      # coordinator accepts them.
      #
      # @api private
      # @param order [Spree::Order] the order to build shipments for
      # @param inventory_units [Array<Spree::InventoryUnit>, nil] the inventory
      #   units to build shipments for
      # @return [Object] an instance of the configured coordinator class
      def build_coordinator(order, inventory_units: nil)
        kwargs = {inventory_units:}.compact

        if accepts_stock_locations?(coordinator_class)
          kwargs[:stock_locations] = stock_locations_for(order)
        else
          Spree.deprecator.warn(
            "#{coordinator_class} should accept a `stock_locations:` keyword " \
            "argument in its initializer. Solidus will always pass it in a " \
            "future version."
          )
        end

        coordinator_class.new(order, **kwargs)
      end

      # The stock locations a coordinator is allowed to allocate inventory
      # from for the given order, in the order it should prefer them.
      #
      # @api private
      # @param order [Spree::Order]
      # @return [Enumerable<Spree::StockLocation>]
      def stock_locations_for(order)
        filtered_stock_locations = location_filter_class.new(
          Spree::StockLocation.all, order
        ).filter

        location_sorter_class.new(filtered_stock_locations).sort
      end

      private

      def accepts_stock_locations?(klass)
        klass.instance_method(:initialize).parameters.any? do |type, name|
          type == :keyrest || (type == :key && name == :stock_locations)
        end
      end
    end
  end
end
