# frozen_string_literal: true

module Spree
  class OrderCancellations
    class CancelledItemsAdjuster
      def initialize(order)
        @order = order
      end

      def adjust!
        order.line_items.each do |line_item|
          line_item.adjustments.select(&:cancellation?).each do |adjustment|
            adjustment.amount = adjustment.source.compute_amount(adjustment.adjustable)
            adjustment.update_columns(amount: adjustment.amount )
          end
        end
      end

      private

      attr_reader :order
    end
  end
end
