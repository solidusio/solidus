# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Discountable
    class Order < SimpleDelegator
      attr_reader :line_items, :shipments

      def initialize(order)
        super
        @line_items = order.line_items.map { |line_item| LineItem.new(line_item, order: self) }
        @shipments = order.shipments.map { |shipment| Shipment.new(shipment, order: self) }
      end

      def order
        __getobj__
      end
    end
  end
end
