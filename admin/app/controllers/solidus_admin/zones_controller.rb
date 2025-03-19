# frozen_string_literal: true

module SolidusAdmin
  class ZonesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::Zone

    def permitted_resource_params
      params.require(:zone).permit(:name, :description, state_ids: [], country_ids: [])
    end
  end
end
