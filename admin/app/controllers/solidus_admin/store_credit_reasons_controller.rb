# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      store_credit_reasons = apply_search_to(
        Spree::StoreCreditReason.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(store_credit_reasons)

      respond_to do |format|
        format.html { render component('store_credit_reasons/index').new(page: @page) }
      end
    end

    def destroy
      @store_credit_reason = Spree::StoreCreditReason.find_by!(id: params[:id])

      Spree::StoreCreditReason.transaction { @store_credit_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to store_credit_reasons_path, status: :see_other
    end

    private

    def load_store_credit_reason
      @store_credit_reason = Spree::StoreCreditReason.find_by!(id: params[:id])
      authorize! action_name, @store_credit_reason
    end

    def store_credit_reason_params
      params.require(:store_credit_reason).permit(:store_credit_reason_id, permitted_store_credit_reason_attributes)
    end
  end
end
