# frozen_string_literal: true

module SolidusPromotions
  module Conditions
    module OrderLevelCondition
      def applicable?(promotable)
        promotable.is_a?(Spree::Order)
      end

      def level
        :order
      end
    end
  end
end
