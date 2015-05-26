module Spree
  # Manage (recalculate) item (LineItem or Shipment) adjustments
  class ItemAdjustments
    attr_reader :item

    delegate :adjustments, :order, to: :item

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
      adjustments.promotion.reload.map do |adjustment|
        adjustment.update!(@item)
      end

      promo_total = PromotionChooser.new(adjustments.promotion).update

      tax = (item.respond_to?(:all_adjustments) ? item.all_adjustments : item.adjustments).tax
      included_tax_total = tax.is_included.reload.map(&:update!).compact.sum
      additional_tax_total = tax.additional.reload.map(&:update!).compact.sum

      item_cancellation_total = adjustments.cancellation.reload.map(&:update!).compact.sum

      item.update_columns(
        :promo_total => promo_total,
        :included_tax_total => included_tax_total,
        :additional_tax_total => additional_tax_total,
        :adjustment_total => promo_total + additional_tax_total + item_cancellation_total,
        :updated_at => Time.now,
      )
    end
  end
end
