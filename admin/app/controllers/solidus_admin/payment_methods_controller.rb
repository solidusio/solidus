# frozen_string_literal: true

module SolidusAdmin
  class PaymentMethodsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search
    include SolidusAdmin::Moveable

    search_scope(:all)
    search_scope(:active, default: true, &:active)
    search_scope(:inactive) { _1.where.not(active: true) }
    search_scope(:storefront, &:available_to_users)
    search_scope(:admin, &:available_to_admin)

    def index
      payment_methods = apply_search_to(
        Spree::PaymentMethod.ordered_by_position,
        param: :q,
      )

      set_page_and_extract_portion_from(payment_methods)

      respond_to do |format|
        format.html { render component('payment_methods/index').new(page: @page) }
      end
    end

    def destroy
      @payment_methods = Spree::PaymentMethod.where(id: params[:id])

      Spree::PaymentMethod.transaction { @payment_methods.destroy_all }

      flash[:notice] = t('.success')
      redirect_back_or_to payment_methods_path, status: :see_other
    end
  end
end
