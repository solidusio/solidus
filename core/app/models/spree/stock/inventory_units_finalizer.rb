# frozen_string_literal: true

module Spree
  module Stock
    # Service class to finalize inventory units, it means unstock the desired
    # quantity from related stock item and updates the given inventory units to
    # not be pending.
    class InventoryUnitsFinalizer
      # @attr_reader [Spree::InventoryUnit] inventory_units to be finalized
      attr_reader :inventory_units

      # @param [Spree::InventoryUnit] inventory_units to be finalized
      def initialize(inventory_units)
        @inventory_units = inventory_units
      end

      # Finalize the inventory units, unstock and mark them as not pending.
      def run!
        Spree::InventoryUnit.transaction do
          unstock_inventory_units
          finalize_inventory_units
        end
      end

      private

      def finalize_inventory_units
        inventory_units.map do |iu|
          iu.update_columns(
            pending: false,
            updated_at: Time.current
          )
        end
      end

      def unstock_inventory_units
        inventory_units.group_by(&:shipment_id).each_value do |inventory_units_for_shipment|
          inventory_units_for_shipment.group_by(&:line_item_id).each_value do |units|
            shipment = units.first.shipment
            line_item = units.first.line_item
            shipment.stock_location.unstock line_item.variant, units.count, shipment
          end
        end
      end
    end
  end
end
