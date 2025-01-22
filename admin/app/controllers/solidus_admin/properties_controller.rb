# frozen_string_literal: true

module SolidusAdmin
  class PropertiesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::Property

    def permitted_resource_params
      params.require(:property).permit(:name, :presentation)
    end

    def resources_collection = Spree::Property.unscoped
  end
end
