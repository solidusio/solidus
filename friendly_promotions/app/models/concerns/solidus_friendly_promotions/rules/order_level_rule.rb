# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Rules
    module OrderLevelRule
      def applicable?(promotable)
        promotable.is_a?(Spree::Order)
      end

      def level
        :order
      end
    end
  end
end
