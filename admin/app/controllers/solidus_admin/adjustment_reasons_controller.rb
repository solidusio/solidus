# frozen_string_literal: true

module SolidusAdmin
  class AdjustmentReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      adjustment_reasons = apply_search_to(
        Spree::AdjustmentReason.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(adjustment_reasons)

      respond_to do |format|
        format.html { render component('adjustment_reasons/index').new(page: @page) }
      end
    end

    def destroy
      @adjustment_reason = Spree::AdjustmentReason.find_by!(id: params[:id])

      Spree::AdjustmentReason.transaction { @adjustment_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to adjustment_reasons_path, status: :see_other
    end

    private

    def load_adjustment_reason
      @adjustment_reason = Spree::AdjustmentReason.find_by!(id: params[:id])
      authorize! action_name, @adjustment_reason
    end

    def adjustment_reason_params
      params.require(:adjustment_reason).permit(:adjustment_reason_id, permitted_adjustment_reason_attributes)
    end
  end
end
