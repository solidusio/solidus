# frozen_string_literal: true

module SolidusAdmin
  class PromotionCategoriesController < SolidusAdmin::BaseController
    before_action :load_promotion_category, only: [:move]

    def index
      @promotion_categories = Spree::PromotionCategory.all

      respond_to do |format|
        format.html { render component('promotion_categories/index').new(promotion_categories: @promotion_categories) }
      end
    end

    def destroy
      @promotion_categories = Spree::PromotionCategory.where(id: params[:id])

      Spree::PromotionCategory.transaction { @promotion_categories.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to promotion_categories_path, status: :see_other
    end

    private

    def load_promotion_category
      @promotion_category = Spree::PromotionCategory.find(params[:id])
      authorize! action_name, @promotion_category
    end
  end
end
