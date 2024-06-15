# frozen_string_literal: true

module SolidusFriendlyPromotions
  module Admin
    class PromotionCategoriesController < BaseController
      private

      def model_class
        SolidusFriendlyPromotions::PromotionCategory
      end
    end
  end
end
