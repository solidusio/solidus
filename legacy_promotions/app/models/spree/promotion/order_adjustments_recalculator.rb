# frozen_string_literal: true

module Spree
  class Promotion < Spree::Base
    # This class encapsulates all the things the promotion system does to
    # an order. It is called from the `Spree::OrderUpdater` before taxes are
    # calculated, such that taxes always respect promotions.

    # This class iterates over all existing promotion adjustments and recalculates
    # their amount and eligibility using their adjustment source.
    class OrderAdjustmentsRecalculator
      def initialize(order)
        @order = order
      end

      def call(persist: true)
        all_items = line_items + shipments
        all_items.each do |item|
          promotion_adjustments = item.adjustments.select(&:promotion?)

          promotion_adjustments.each { |adjustment| recalculate(adjustment, persist:) }
          Spree::Config.promotions.promotion_chooser_class.new(promotion_adjustments).update

          item.promo_total = promotion_adjustments.select(&:eligible?).sum(&:amount)
        end
        # Update and select the best promotion adjustment for the order.
        # We don't update the order.promo_total yet. Order totals are updated later
        # in #update_adjustment_total since they include the totals from the order's
        # line items and/or shipments.
        order_promotion_adjustments = order.adjustments.select(&:promotion?)
        order_promotion_adjustments.each { |adjustment| recalculate(adjustment, persist:) }
        Spree::Config.promotions.promotion_chooser_class.new(order_promotion_adjustments).update

        order.promo_total = all_items.sum(&:promo_total) +
                            order_promotion_adjustments.
                              select(&:eligible?).
                              select(&:promotion?).
                              sum(&:amount)

        order.save! if persist
        order
      end

      private

      attr_reader :order

      delegate :line_items, :shipments, to: :order

      # Recalculate and persist the amount from this adjustment's source based on
      # the adjustable ({Order}, {Shipment}, or {LineItem})
      #
      # If the adjustment has no source (such as when created manually from the
      # admin) or is closed, this is a noop.
      #
      # @return [BigDecimal] New amount of this adjustment
      def recalculate(adjustment, persist:)
        if adjustment.finalized?
          return adjustment.amount
        end

        # If the adjustment has no source, do not attempt to re-calculate the
        # amount.
        # Some scenarios where this happens:
        #   - Adjustments that are manually created via the admin backend
        #   - PromotionAction adjustments where the PromotionAction was deleted
        #     after the order was completed.
        if adjustment.source.present?
          adjustment.amount = adjustment.source.compute_amount(adjustment.adjustable)

          adjustment.eligible = calculate_eligibility(adjustment)

          adjustment.save!(validate: false) if persist
        end
        adjustment.amount
      end

      # Calculates based on attached promotion (if this is a promotion
      # adjustment) whether this promotion is still eligible.
      # @api private
      # @return [true,false] Whether this adjustment is eligible
      def calculate_eligibility(adjustment)
        if !adjustment.finalized? && adjustment.source
          adjustment.source.promotion.eligible?(adjustment.adjustable, promotion_code: adjustment.promotion_code)
        else
          adjustment.eligible?
        end
      end
    end
  end
end
