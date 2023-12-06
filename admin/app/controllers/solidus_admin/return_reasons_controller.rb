# frozen_string_literal: true

module SolidusAdmin
  class ReturnReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      return_reasons = apply_search_to(
        Spree::ReturnReason.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(return_reasons)

      respond_to do |format|
        format.html { render component('return_reasons/index').new(page: @page) }
      end
    end

    def destroy
      @return_reason = Spree::ReturnReason.find_by!(id: params[:id])

      Spree::ReturnReason.transaction { @return_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to return_reasons_path, status: :see_other
    end

    private

    def load_return_reason
      @return_reason = Spree::ReturnReason.find_by!(id: params[:id])
      authorize! action_name, @return_reason
    end

    def return_reason_params
      params.require(:return_reason).permit(:return_reason_id, permitted_return_reason_attributes)
    end
  end
end
