# frozen_string_literal: true

module SolidusLegacyPromotions
  module SpreeShipmentPatch
    # @return [BigDecimal] the amount of this item, taking into consideration
    #   all non-tax eligible adjustments.
    def total_before_tax
      amount + adjustments.select { |adjustment| !adjustment.tax? && adjustment.eligible? }.sum(&:amount)
    end

    Spree::Shipment.prepend self
  end
end
