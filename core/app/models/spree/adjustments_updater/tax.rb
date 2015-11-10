# Tax adjustments come in not one but *two* exciting flavours:
# Included & additional

# Included tax adjustments are those which are included in the price.
# These ones should not affect the eventual total price.
#
# Additional tax adjustments are the opposite, affecting the final total.
module Spree
  module AdjustmentsUpdater
    class Tax

      def initialize(adjustableUpdater)
        @adjustableUpdater = adjustableUpdater
      end

      def update
        tax = adjustments.select(&:tax?)

        included_tax_total = tax.select(&:included?).map(&:update!).compact.sum
        additional_tax_total = tax.reject(&:included?).map(&:update!).compact.sum

        @adjustableUpdater.set_attribute(:included_tax_total, included_tax_total, false)
        @adjustableUpdater.set_attribute(:additional_tax_total, additional_tax_total)
      end

      private

      def adjustments
        @adjustments ||= @adjustableUpdater.adjustments
      end
    end
  end
end
