# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeInMemoryOrderUpdaterPatch
    def update_adjustment_total(persist:)
      update_adjustments(persist:)

      all_items = (line_items + shipments).reject(&:marked_for_destruction?)
      valid_adjustments = adjustments.select(&:eligible?).reject(&:marked_for_destruction?)
      order_tax_adjustments = valid_adjustments.select(&:tax?)

      order.adjustment_total = all_items.sum(&:adjustment_total) + valid_adjustments.sum(&:amount)
      order.included_tax_total = all_items.sum(&:included_tax_total) + order_tax_adjustments.select(&:included?).sum(&:amount)
      order.additional_tax_total = all_items.sum(&:additional_tax_total) + order_tax_adjustments.reject(&:included?).sum(&:amount)

      recalculate_order_total
    end

    def assign_item_totals
      [*line_items, *shipments].each do |item|
        Spree::Config.item_total_class.new(item).recalculate!

        # The cancellation_total isn't persisted anywhere but is included in
        # the adjustment_total.
        #
        # Core doesn't have "eligible" adjustments anymore, so we need to
        # override the adjustment_total calculation to exclude them for legacy
        # promotions.
        item.adjustment_total = item.adjustments.
          select(&:eligible?).
          reject(&:included?).
          reject(&:marked_for_destruction?).
          sum(&:amount)
      end
    end

    Spree::InMemoryOrderUpdater.prepend self
  end
end
