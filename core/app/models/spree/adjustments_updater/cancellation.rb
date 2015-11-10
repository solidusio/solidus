module Spree
  module AdjustmentsUpdater
    class Cancellation

      def initialize(adjustableUpdater)
        @adjustableUpdater = adjustableUpdater
      end

      def update
        item_cancellation_total = adjustments.select(&:cancellation?).map(&:update!).compact.sum

        @adjustableUpdater.add_to_adjustment_total(item_cancellation_total)
      end

      private

      def adjustments
        @adjustableUpdater.adjustments
      end
    end
  end
end
