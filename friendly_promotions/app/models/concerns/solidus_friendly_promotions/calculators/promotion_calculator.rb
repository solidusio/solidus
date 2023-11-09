# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Calculators
    module PromotionCalculator
      def description
        self.class.human_attribute_name(:description)
      end
    end
  end
end
