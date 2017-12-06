# frozen_string_literal: true

module Spree
  module Events
    class OrderInventoryCancelledEvent
      attr_reader :order_id, :inventory_unit_ids

      def initialize(order_id:, inventory_unit_ids:)
        @order_id = order_id
        @inventory_units_ids = inventory_unit_ids
      end
    end
  end
end
