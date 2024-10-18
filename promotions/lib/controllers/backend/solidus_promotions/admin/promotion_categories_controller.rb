# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class PromotionCategoriesController < BaseController
      private

      def model_class
        SolidusPromotions::PromotionCategory
      end
    end
  end
end
