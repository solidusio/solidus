# frozen_string_literal: true

module SolidusPromotions
  class PromotionCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      promotion_categories = apply_search_to(
        SolidusPromotions::PromotionCategory.all,
        param: :q
      )

      set_page_and_extract_portion_from(promotion_categories)

      respond_to do |format|
        format.html { render component("solidus_promotions/categories/index").new(page: @page) }
      end
    end

    def destroy
      @promotion_categories = SolidusPromotions::PromotionCategory.where(id: params[:id])

      SolidusPromotions::PromotionCategory.transaction { @promotion_categories.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to solidus_promotions.promotion_categories_path, status: :see_other
    end

    private

    def authorization_subject
      SolidusPromotions::PromotionCategory
    end
  end
end
