module Spree
  # Manage (recalculate) item (LineItem or Shipment) adjustments
  class ItemAdjustments
    include ActiveSupport::Callbacks
    define_callbacks :promo_adjustments, :tax_adjustments
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
      promo_total = 0
      run_callbacks :promo_adjustments do
        adjustments.promotion.reload.map do |adjustment|
          adjustment.update!(@item)
        end

        choose_best_promotion_adjustment
        promo_total = best_promotion_adjustment.try(:amount) || 0
      end

      included_tax_total = 0
      additional_tax_total = 0
      run_callbacks :tax_adjustments do
        tax = (item.respond_to?(:all_adjustments) ? item.all_adjustments : item.adjustments).tax
        included_tax_total = tax.is_included.reload.map(&:update!).compact.sum
        additional_tax_total = tax.additional.reload.map(&:update!).compact.sum
      end

      item_cancellation_total = adjustments.cancellation.reload.map(&:update!).compact.sum

      item.update_columns(
        :promo_total => promo_total,
        :included_tax_total => included_tax_total,
        :additional_tax_total => additional_tax_total,
        :adjustment_total => promo_total + additional_tax_total + item_cancellation_total,
        :updated_at => Time.now,
      )
    end

    def promotion_chooser
      @promotion_chooser ||= PromotionChooser.new(adjustments.promotion)
    end

    def choose_best_promotion_adjustment
      promotion_chooser.update
    end

    def best_promotion_adjustment
      promotion_chooser.best_promotion_adjustment
    end
  end
end
