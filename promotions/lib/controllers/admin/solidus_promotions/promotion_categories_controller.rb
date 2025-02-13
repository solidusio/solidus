# frozen_string_literal: true

module SolidusPromotions
  class PromotionCategoriesController < SolidusAdmin::ResourcesController
    private

    def resource_class = SolidusPromotions::PromotionCategory

    def permitted_resource_params
      params.require(:promotion_category).permit(:name, :code)
    end

    def resources_collection = SolidusPromotions::PromotionCategory.unscoped

    def index_component
      component("solidus_promotions/categories/index")
    end

    def new_component
      component("solidus_promotions/categories/new")
    end

    def edit_component
      component("solidus_promotions/categories/edit")
    end

    def after_create_path
      solidus_promotions.promotion_categories_path(**search_filter_params)
    end

    def after_update_path
      solidus_promotions.promotion_categories_path(**search_filter_params)
    end

    def after_destroy_path
      solidus_promotions.promotion_categories_path(**search_filter_params)
    end

    def authorization_subject
      SolidusPromotions::PromotionCategory
    end
  end
end
