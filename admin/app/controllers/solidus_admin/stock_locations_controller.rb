# frozen_string_literal: true

module SolidusAdmin
  class StockLocationsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::StockLocation

    def permitted_resource_params
      params.require(:stock_location).permit(
        :name,
        :admin_name,
        :code,
        :address1,
        :address2,
        :city, :zipcode,
        :country_id,
        :state_name,
        :state_id,
        :phone,
        :active,
        :default,
        :backorderable_default,
        :propagate_all_variants,
        :restock_inventory,
        :fulfillable,
        :check_stock_on_transfer
      )
    end

    def resources_collection = Spree::StockLocation.unscoped
  end
end
