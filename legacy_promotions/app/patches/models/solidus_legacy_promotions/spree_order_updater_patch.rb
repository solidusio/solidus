# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeOrderUpdaterPatch
    def update_adjustment_total
      recalculate_adjustments

      all_items = line_items + shipments
      order_tax_adjustments = adjustments.select(&:eligible?).select(&:tax?)

      order.adjustment_total = all_items.sum(&:adjustment_total) + adjustments.select(&:eligible?).sum(&:amount)
      order.included_tax_total = all_items.sum(&:included_tax_total) + order_tax_adjustments.select(&:included?).sum(&:amount)
      order.additional_tax_total = all_items.sum(&:additional_tax_total) + order_tax_adjustments.reject(&:included?).sum(&:amount)

      update_order_total
    end

    def update_item_totals
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
          sum(&:amount)

        if item.changed?
          item.update_columns(
            promo_total:          item.promo_total,
            included_tax_total:   item.included_tax_total,
            additional_tax_total: item.additional_tax_total,
            adjustment_total:     item.adjustment_total,
            updated_at:           Time.current,
          )
        end
      end
    end
    Spree::OrderUpdater.prepend self
  end
end
