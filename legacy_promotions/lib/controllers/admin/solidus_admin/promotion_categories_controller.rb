# frozen_string_literal: true

module SolidusAdmin
  class PromotionCategoriesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::PromotionCategory

    def permitted_resource_params
      params.require(:promotion_category).permit(:name, :code)
    end

    def resources_collection = Spree::PromotionCategory.unscoped
  end
end
