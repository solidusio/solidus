# frozen_string_literal: true

module SolidusFriendlyPromotions
  class OrderDiscounter
    def initialize(order)
      @order = order
    end

    def call
      discountable_order = FriendlyPromotionDiscounter.new(order).call

      discountable_order.line_items.each do |line_item|
        update_adjustments(line_item, line_item.current_discounts)
      end

      discountable_order.shipments.each do |shipment|
        update_adjustments(shipment, shipment.current_discounts)
      end

      discountable_order.shipments.flat_map(&:shipping_rates).each do |shipping_rate|
        shipping_rate.discounts = shipping_rate.current_discounts.map do |discount|
          SolidusFriendlyPromotions::ShippingRateDiscount.create!(
            shipping_rate: shipping_rate,
            amount: discount.amount,
            label: discount.label,
            promotion_action: discount.source
          )
        end
      end

      order.promo_total = (order.line_items + order.shipments).sum(&:promo_total)
      order
    end

    private

    attr_reader :order

    # Walk through the discounts for an item and update adjustments for it. Once
    # all of the discounts have been added as adjustments, remove any old tax
    # adjustments that weren't touched.
    #
    # @private
    # @param [#adjustments] item a {Spree::LineItem} or {Spree::Shipment}
    # @param [Array<SolidusFriendlyPromotions::ItemDiscount>] item_discounts a list of calculated discounts for an item
    # @return [void]
    def update_adjustments(item, item_discounts)
      promotion_adjustments = item.adjustments.select(&:promotion?)

      active_adjustments = item_discounts.map do |item_discount|
        update_adjustment(item, item_discount)
      end
      item.update(promo_total: active_adjustments.sum(&:amount))
      # Remove any tax adjustments tied to promotion actions which no longer match.
      unmatched_adjustments = promotion_adjustments - active_adjustments

      item.adjustments.destroy(unmatched_adjustments)
    end

    # Update or create a new tax adjustment on an item.
    #
    # @private
    # @param [#adjustments] item a {Spree::LineItem} or {Spree::Shipment}
    # @param [SolidusFriendlyPromotions::ItemDiscount] tax_item calculated discounts for an item
    # @return [Spree::Adjustment] the created or updated tax adjustment
    def update_adjustment(item, discount_item)
      adjustment = item.adjustments.detect do |item_adjustment|
        item_adjustment.source == discount_item.source
      end

      adjustment ||= item.adjustments.new(
        source: discount_item.source,
        order_id: item.is_a?(Spree::Order) ? item.id : item.order_id,
        label: discount_item.label,
        eligible: true
      )
      adjustment.update!(amount: discount_item.amount)
      adjustment
    end
  end
end
