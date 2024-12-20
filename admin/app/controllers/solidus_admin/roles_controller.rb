# frozen_string_literal: true

module SolidusAdmin
  class RolesController < SolidusAdmin::ResourcesController
    search_scope(:all)
    search_scope(:admin) { _1.where(name: "admin") }

    private

    def resource_class = Spree::Role

    def permitted_resource_params
      params.require(:role).permit(:role_id, :name, :description, permission_set_ids: [])
    end
  end
end
