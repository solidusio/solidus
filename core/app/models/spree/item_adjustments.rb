module Spree
  # Manage (recalculate) item (LineItem or Shipment) adjustments
  class ItemAdjustments
    attr_reader :item

    # @param item [Order, LineItem, Shipment] the item whose adjustments should be updated
    def initialize(item)
      @item = item
    end

    # Update the item's adjustments and totals
    #
    # If the item is an {Order}, this will update and select the best
    # promotion adjustment.
    #
    # If it is a {LineItem} or {Shipment}, it will update and select the best
    # promotion adjustment, update tax adjustments, update cancellation
    # adjustments, and then update the total fields (promo_total,
    # included_tax_total, additional_tax_total, and adjustment_total) on the
    # item.
    #
    # This is a noop if the item is not persisted.
    def update
      return @item unless item.persisted?

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
      promotion_adjustments.each(&:update!)

      promo_total = Spree::Config.promotion_chooser_class.new(promotion_adjustments).update

      # Calculating the totals for the order here would be incorrect. Order's
      # totals are the sum of the adjustments on all child models, as well as
      # its own.
      #
      # We want to select the best promotion for the order, but the remainder
      # of the calculations here are done in the OrderUpdater instead.
      return if item.is_a?(Spree::Order)

      @item.promo_total = promo_total

      tax = adjustments.select(&:tax?)

      @item.included_tax_total = tax.select(&:included?).map(&:update!).compact.sum
      @item.additional_tax_total = tax.reject(&:included?).map(&:update!).compact.sum

      item_cancellation_total = adjustments.select(&:cancellation?).map(&:update!).compact.sum

      @item.adjustment_total = @item.promo_total + @item.additional_tax_total + item_cancellation_total

      @item.update_columns(
        promo_total: @item.promo_total,
        included_tax_total: @item.included_tax_total,
        additional_tax_total: @item.additional_tax_total,
        adjustment_total: @item.adjustment_total,
        updated_at: Time.current
      ) if @item.changed?

      # In rails 4.2 update_columns isn't reflected in the changed_attributes hash,
      # which means that multiple updates on the same in-memory model will
      # behave incorrectly.
      # In rails 5.0 changed_attributes works with update_columns and this is
      # unnecessary.
      item.attributes_changed_by_setter.except!(:promo_total, :included_tax_total, :additional_tax_total, :adjustment_total)

      @item
    end

    private

    def adjustments
      @adjustments ||= item.adjustments.to_a
    end
  end
end
