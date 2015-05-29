module Spree
  # Manage (recalculate) item (LineItem or Shipment) adjustments
  class ItemAdjustments
    attr_reader :item

    def initialize(item)
      @item = item
    end

    def update
      update_adjustments if item.persisted?
      item
    end

    # TODO this should be probably the place to calculate proper item taxes
    # values after promotions are applied
    def update_adjustments
      # Promotion adjustments must be applied first, then tax adjustments.
      # This fits the criteria for VAT tax as outlined here:
      # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
      #
      # It also fits the criteria for sales tax as outlined here:
      # http://www.boe.ca.gov/formspubs/pub113/
      #
      # Tax adjustments come in not one but *two* exciting flavours:
      # Included & additional

      # Included tax adjustments are those which are included in the price.
      # These ones should not affect the eventual total price.
      #
      # Additional tax adjustments are the opposite, affecting the final total.

      promotion_adjustments = adjustments.select(&:promotion?)

      promotion_adjustments.each do |adjustment|
        adjustment.update!
      end

      promo_total = PromotionChooser.new(promotion_adjustments).update

      # Calculating the totals for the order here would be incorrect. Order's
      # totals are the sum of the adjustments on all child models, as well as
      # its own.
      return if Spree::Order === item

      tax = adjustments.select(&:tax?)

      included_tax_total = tax.select(&:included?).map(&:update!).compact.sum
      additional_tax_total = tax.reject(&:included?).map(&:update!).compact.sum

      item_cancellation_total = adjustments.select(&:cancellation?).map(&:update!).compact.sum

      item.update_columns(
        :promo_total => promo_total,
        :included_tax_total => included_tax_total,
        :additional_tax_total => additional_tax_total,
        :adjustment_total => promo_total + additional_tax_total + item_cancellation_total,
        :updated_at => Time.now,
      )
    end

    private
    def adjustments
      # This is done intentionally to avoid loading the association. If the
      # association is loaded, the records may become stale due to code
      # elsewhere in spree. When that is remedied, this should be changed to
      # just item.adjustments
      @adjustments ||= item.adjustments.all.to_a
    end
  end
end
