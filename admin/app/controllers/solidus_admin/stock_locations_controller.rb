# frozen_string_literal: true

module SolidusAdmin
  class StockLocationsController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::StockLocation

    def resources_collection = Spree::StockLocation.unscoped
  end
end
