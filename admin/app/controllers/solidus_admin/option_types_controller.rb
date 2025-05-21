# frozen_string_literal: true

module SolidusAdmin
  class OptionTypesController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    private

    def after_create_path
      solidus_admin.edit_option_type_path(@resource)
    end

    def resource_class = Spree::OptionType

    def permitted_resource_params
      params.require(:option_type).permit(:name, :presentation)
    end

    def resources_collection = Spree::OptionType.unscoped

    def resources_sorting_options
      { position: :asc }
    end
  end
end
