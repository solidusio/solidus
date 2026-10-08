# frozen_string_literal: true

module SolidusPromotions
  module Admin
    class PromotionCategoriesController < BaseController
      private

      def permitted_resource_params
        params.require(:promotion_category).permit(:name, :code)
      end

      def model_class
        SolidusPromotions::PromotionCategory
      end
    end
  end
end
