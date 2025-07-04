# frozen_string_literal: true

module SolidusPromotions
  class OrderAdjuster
    class PersistDiscountedOrder
      def initialize(order)
        @order = order
      end

      def call
        order.line_items.each do |line_item|
          update_adjustments(line_item, line_item.current_discounts)
        end

        order.shipments.each do |shipment|
          update_adjustments(shipment, shipment.current_discounts)
        end

        order.shipments.flat_map(&:shipping_rates).each do |shipping_rate|
          shipping_rate.discounts = shipping_rate.current_discounts.map do |discount|
            SolidusPromotions::ShippingRateDiscount.create!(
              shipping_rate: shipping_rate,
              amount: discount.amount,
              label: discount.label,
              benefit: discount.source
            )
          end
        end
        order.reset_current_discounts
        order
      end

      private

      attr_reader :order

      # Walk through the discounts for an item and update adjustments for it.
      # Once all of the discounts have been added as adjustments, mark any old
      # promotion adjustments that weren't touched for destruction.
      #
      # @private
      # @param [#adjustments] item a {Spree::LineItem} or {Spree::Shipment}
      # @param [Array<SolidusPromotions::ItemDiscount>] item_discounts a list of
      #   calculated discounts for an item
      # @return [void]
      def update_adjustments(item, item_discounts)
        promotion_adjustments = item.adjustments.select(&:promotion?)

        active_adjustments = item_discounts.map do |item_discount|
          update_adjustment(item, item_discount)
        end
        item.update(promo_total: active_adjustments.sum(&:amount))
        # Remove any promotion adjustments tied to promotion benefits which no longer match.
        unmatched_adjustments = promotion_adjustments - active_adjustments

        unmatched_adjustments.each(&:mark_for_destruction)
      end

      # Update or create a new promotion adjustment on an item.
      #
      # @private
      # @param [#adjustments] item a {Spree::LineItem} or {Spree::Shipment}
      # @param [SolidusPromotions::ItemDiscount] discount_item calculated discounts for an item
      # @return [Spree::Adjustment] the created or updated promotion adjustment
      def update_adjustment(item, discount_item)
        adjustment = item.adjustments.detect do |item_adjustment|
          item_adjustment.source == discount_item.source
        end

        adjustment ||= item.adjustments.new(
          source: discount_item.source,
          order_id: item.is_a?(Spree::Order) ? item.id : item.order_id,
          label: discount_item.label
        )
        adjustment.update!(amount: discount_item.amount)
        adjustment
      end
    end
  end
end
