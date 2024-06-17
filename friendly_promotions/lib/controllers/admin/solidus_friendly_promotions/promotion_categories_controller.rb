# frozen_string_literal: true

module SolidusFriendlyPromotions
  class PromotionCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      promotion_categories = apply_search_to(
        SolidusFriendlyPromotions::PromotionCategory.all,
        param: :q
      )

      set_page_and_extract_portion_from(promotion_categories)

      respond_to do |format|
        format.html { render component("promotion_categories/index").new(page: @page) }
      end
    end

    def destroy
      @promotion_categories = SolidusFriendlyPromotions::PromotionCategory.where(id: params[:id])

      SolidusFriendlyPromotions::PromotionCategory.transaction { @promotion_categories.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to solidus_friendly_promotions.promotion_categories_path, status: :see_other
    end
  end
end
