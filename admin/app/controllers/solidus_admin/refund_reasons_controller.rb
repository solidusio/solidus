# frozen_string_literal: true

module SolidusAdmin
  class RefundReasonsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::RefundReason

    def resources_collection = Spree::RefundReason.unscoped

    def permitted_resource_params
      params.require(:refund_reason).permit(:name, :code, :active)
    end
  end
end
