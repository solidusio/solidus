# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base

    # This class encapsulates all the things the promotion system does to
    # an order.
    class OrderAdjustmentsRecalculator
      def initialize(order)
        @order = order
      end

      def adjust!
        [*line_items, *shipments].each do |item|
          promotion_adjustments = item.adjustments.select(&:promotion?)

          promotion_adjustments.each(&:recalculate)
          Spree::Config.promotion_chooser_class.new(promotion_adjustments).update
        end
        # Update and select the best promotion adjustment for the order.
        # We don't update the order.promo_total yet. Order totals are updated later
        # in #update_adjustment_total since they include the totals from the order's
        # line items and/or shipments.
        order_promotion_adjustments = order.adjustments.select(&:promotion?)
        order_promotion_adjustments.each(&:recalculate)
        Spree::Config.promotion_chooser_class.new(order_promotion_adjustments).update
      end

      private

      attr_reader :order
      delegate :line_items, :shipments, to: :order
    end
  end
end
