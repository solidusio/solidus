# frozen_string_literal: true

module Spree
  module Stock
    class Coordinator
      class Context
        attr_reader :order
        attr_accessor :inventory_units, :inventory_unit_groups, :stock_locations,
          :desired, :availability, :on_hand_packages, :backordered_packages,
          :packages, :shipments

        def initialize(order:, inventory_units: nil)
          @order = order
          @inventory_units = inventory_units
        end
      end
    end
  end
end
