# frozen_string_literal: true

module SolidusAdmin
  class ReturnReasonsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::ReturnReason

    def resources_collection = Spree::ReturnReason.unscoped

    def permitted_resource_params
      params.require(:return_reason).permit(:name, :active)
    end
  end
end
