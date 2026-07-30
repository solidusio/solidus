# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      class Context
        attr_reader :order
        attr_accessor :inventory_units, :inventory_unit_groups, :stock_locations,
          :on_hand_packages, :backordered_packages,
          :packages, :shipments

        def initialize(order:, inventory_units: nil)
          @order = order
          @inventory_units = inventory_units
        end

        def desired
          @desired ||= Spree::StockQuantities.new(inventory_unit_groups.transform_values(&:count))
        end

        def availability
          @availability ||= Spree::Stock::Availability.new(
            variants: desired.variants,
            stock_locations: stock_locations
          )
        end
      end
    end
  end
end
