# frozen_string_literal: true

module SolidusAdmin
  class PromotionCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      promotion_categories = apply_search_to(
        Spree::PromotionCategory.all,
        param: :q,
      )

      set_page_and_extract_portion_from(promotion_categories)

      respond_to do |format|
        format.html { render component('promotion_categories/index').new(page: @page) }
      end
    end

    def destroy
      @promotion_categories = Spree::PromotionCategory.where(id: params[:id])

      Spree::PromotionCategory.transaction { @promotion_categories.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to promotion_categories_path, status: :see_other
    end
  end
end
