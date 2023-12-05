# frozen_string_literal: true

module SolidusAdmin
  class ShippingCategoriesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      shipping_categories = apply_search_to(
        Spree::ShippingCategory.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(shipping_categories)

      respond_to do |format|
        format.html { render component('shipping_categories/index').new(page: @page) }
      end
    end

    def destroy
      @shipping_category = Spree::ShippingCategory.find_by!(id: params[:id])

      Spree::ShippingCategory.transaction { @shipping_category.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to shipping_categories_path, status: :see_other
    end

    private

    def load_shipping_category
      @shipping_category = Spree::ShippingCategory.find_by!(id: params[:id])
      authorize! action_name, @shipping_category
    end

    def shipping_category_params
      params.require(:shipping_category).permit(:shipping_category_id, permitted_shipping_category_attributes)
    end
  end
end
