# frozen_string_literal: true

module SolidusAdmin
  class ReimbursementTypesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::ReimbursementType

    def resources_collection = Spree::ReimbursementType.unscoped

    def permitted_resource_params
      params.require(:reimbursement_type).permit(:name, :active)
    end
  end
end
