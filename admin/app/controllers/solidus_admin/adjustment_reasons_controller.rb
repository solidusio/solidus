# frozen_string_literal: true

module SolidusAdmin
  class AdjustmentReasonsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::AdjustmentReason

    def permitted_resource_params
      params.require(:adjustment_reason).permit(:name, :code, :active)
    end
  end
end
