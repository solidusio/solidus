# frozen_string_literal: true

module Spree
  module Admin
    class PromotionCategoriesController < ResourceController
      private

      def permitted_resource_params
        params.require(:promotion_category).permit(:name, :code)
      end
    end
  end
end
