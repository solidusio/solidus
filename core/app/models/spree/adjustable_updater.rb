module Spree
  class AdjustableUpdater
    attr_reader :adjustable

    def self.update(adjustable)
      return adjustable unless adjustable.persisted?

      adjustableUpdater = Spree::AdjustableUpdater.new(adjustable)

      # Promotion adjustments must be applied first, then tax adjustments.
      # This fits the criteria for VAT tax as outlined here:
      # http://www.hmrc.gov.uk/vat/managing/charging/discounts-etc.htm#1
      #
      # It also fits the criteria for sales tax as outlined here:
      # http://www.boe.ca.gov/formspubs/pub113/

      # Rails.application.config.spree.adjustments_updater.pre_tax_updaters.each { |adjusterKlass| adjusterKlass.new(adjustableUpdate).update }
      Spree::AdjustmentsUpdater::Promotion.new(adjustableUpdater).update

      # We want to select the best promotion for the order, but the remainder
      # of the calculations here are done in the OrderUpdater instead.
      return if Spree::Order === adjustable

      # Rails.application.config.spree.adjustments_updater.tax_updater.new(adjustableUpdater).update
      # Rails.application.config.spree.adjustments_updater.post_tax_updaters.each { |adjusterKlass| adjusterKlass.new(adjustableUpdate).update }
      Spree::AdjustmentsUpdater::Tax.new(adjustableUpdater).update
      Spree::AdjustmentsUpdater::Cancellation.new(adjustableUpdater).update

      adjustableUpdater.persist if adjustable.changed?

      adjustableUpdater.adjustable
    end

    # @param adjustable [Order, LineItem, Shipment] the item whose adjustments should be updated
    def initialize(adjustable)
      @adjustable = adjustable
      @attributes_to_persist = {adjustment_total: 0}
    end

    def set_attribute(attribute, value, include_in_adjustment_total = true)
      # Setting totals for the order here would be incorrect. Order's
      # totals are the sum of the adjustments on all child models, as well as
      # its own.
      return if Spree::Order === adjustable

      adjustable.send("#{attribute}=", value)
      @attributes_to_persist[attribute] = value

      add_to_adjustment_total(value) if include_in_adjustment_total
    end

    def add_to_adjustment_total(value)
      adjustable.adjustment_total += value
      @attributes_to_persist[:adjustment_total] += value
    end

    def adjustments
      # This is done intentionally to avoid loading the association. If the
      # association is loaded, the records may become stale due to code
      # elsewhere in Spree. When that is remedied, this should be changed to
      # just item.adjustments
      @adjustments ||= adjustable.adjustments.all.to_a
    end

    def persist
      attributes = @attributes_to_persist
      attributes[:updated_at] = Time.current

      adjustable.update_columns(attributes)
    end
  end
end
