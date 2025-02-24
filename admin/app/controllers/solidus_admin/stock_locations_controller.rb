# frozen_string_literal: true

module SolidusAdmin
  class StockLocationsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::StockLocation

    def permitted_resource_params
      params.require(:stock_location).permit(:name, :admin_name, :code)
    end

    def resources_collection = Spree::StockLocation.unscoped
  end
end
