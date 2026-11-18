# frozen_string_literal: true

module SolidusAdmin
  class ProductPropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ProductSpecifications

    def new
      @product_property = @product.product_properties.build

      respond_to do |format|
        format.turbo_stream
      end
    end

    def edit
      respond_with_form
    end

    def update
      if @product.update(product_properties_params)
        respond_with_success(t(".success"))
      else
        respond_with_errors
      end
    end

    private

    def product_properties_params
      params.require(:product).permit(product_properties_attributes: [:id, :property_name, :value, :_destroy])
    end
  end
end
