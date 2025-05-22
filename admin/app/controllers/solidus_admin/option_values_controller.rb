# frozen_string_literal: true

module SolidusAdmin
  class OptionValuesController < SolidusAdmin::ResourcesController
    include SolidusAdmin::Moveable

    before_action :set_option_type, only: [:new, :create]

    def new
      @resource = @option_type.option_values.build
      super
    end

    def create
      @resource = @option_type.option_values.build(permitted_resource_params)
      super
    end

    private

    def resource_class = Spree::OptionValue

    def permitted_resource_params
      params.require(:option_value).permit(:name, :presentation)
    end

    def resource_form_frame
      :option_value_modal
    end

    def after_create_path
      solidus_admin.edit_option_type_path(@option_type)
    end

    def after_update_path
      solidus_admin.edit_option_type_path(@option_value.option_type)
    end

    def set_option_type
      @option_type = Spree::OptionType.find(params[:option_type_id])
    end
  end
end
