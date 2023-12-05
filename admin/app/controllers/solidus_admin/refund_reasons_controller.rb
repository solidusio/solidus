# frozen_string_literal: true

module SolidusAdmin
  class RefundReasonsController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      refund_reasons = apply_search_to(
        Spree::RefundReason.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(refund_reasons)

      respond_to do |format|
        format.html { render component('refund_reasons/index').new(page: @page) }
      end
    end

    def destroy
      @refund_reason = Spree::RefundReason.find_by!(id: params[:id])

      Spree::RefundReason.transaction { @refund_reason.destroy }

      flash[:notice] = t('.success')
      redirect_back_or_to refund_reasons_path, status: :see_other
    end

    private

    def load_refund_reason
      @refund_reason = Spree::RefundReason.find_by!(id: params[:id])
      authorize! action_name, @refund_reason
    end

    def refund_reason_params
      params.require(:refund_reason).permit(:refund_reason_id, permitted_refund_reason_attributes)
    end
  end
end
