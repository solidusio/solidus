# frozen_string_literal: true

module SolidusAdmin
  class ShippingMethodsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      shipping_methods = apply_search_to(
        Spree::ShippingMethod.order(id: :desc),
        param: :q
      )

      set_page_and_extract_portion_from(shipping_methods)

      respond_to do |format|
        format.html { render component("shipping_methods/index").new(page: @page) }
      end
    end

    def destroy
      @shipping_methods = Spree::ShippingMethod.where(id: params[:id])

      Spree::ShippingMethod.transaction { @shipping_methods.destroy_all }

      flash[:notice] = t(".success")
      redirect_back_or_to shipping_methods_path, status: :see_other
    end

    private

    def shipping_method_params
      params.require(:shipping_method).permit(:shipping_method_id, permitted_shipping_method_attributes)
    end
  end
end
