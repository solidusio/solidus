# frozen_string_literal: true

module SolidusPromotions
  module Benefits
    module OrderBenefit
      def can_discount?(_)
        false
      end

      def level
        :order
      end
    end
  end
end
