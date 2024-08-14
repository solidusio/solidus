# frozen_string_literal: true

module SolidusAdmin
  class ReimbursementTypesController < SolidusAdmin::BaseController
    include SolidusAdmin::ControllerHelpers::Search

    def index
      reimbursement_types = apply_search_to(
        Spree::ReimbursementType.unscoped.order(id: :desc),
        param: :q,
      )

      set_page_and_extract_portion_from(reimbursement_types)

      respond_to do |format|
        format.html { render component('reimbursement_types/index').new(page: @page) }
      end
    end

    private

    def reimbursement_type_params
      params.require(:reimbursement_type).permit(:reimbursement_type_id, permitted_reimbursement_type_attributes)
    end
  end
end
