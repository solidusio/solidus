module Spree
  module AdjustmentsUpdater
    class Promotion

      def initialize(adjustableUpdater)
        @adjustableUpdater = adjustableUpdater
      end

      def update
        promotion_adjustments = adjustments.select(&:promotion?)
        promotion_adjustments.each(&:update!)

        promo_total = Spree::Config.promotion_chooser_class.new(promotion_adjustments).update

        @adjustableUpdater.set_attribute(:promo_total, promo_total)
      end

      private

      def adjustments
        @adjustments ||= @adjustableUpdater.adjustments
      end
    end
  end
end
