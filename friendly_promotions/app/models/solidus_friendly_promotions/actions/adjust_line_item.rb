# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Actions
    class AdjustLineItem < Base
      class_attribute :available_calculators, default: []

      def can_adjust?(object)
        object.is_a? Spree::LineItem
      end
    end
  end
end
