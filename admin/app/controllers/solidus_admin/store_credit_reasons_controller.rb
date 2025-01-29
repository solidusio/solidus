# frozen_string_literal: true

module SolidusAdmin
  class StoreCreditReasonsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::StoreCreditReason

    def resources_collection = Spree::StoreCreditReason.unscoped

    def permitted_resource_params
      params.require(:store_credit_reason).permit(:name, :active)
    end
  end
end
