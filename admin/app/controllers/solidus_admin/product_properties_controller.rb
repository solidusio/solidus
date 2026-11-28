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
      if update_product
        respond_with_success(t(".success"))
      else
        respond_with_errors
      end
    end

    private

    def update_product
      Spree::ProductProperty.acts_as_list_no_update { @product.update(product_properties_params) }
    end

    def product_properties_params
      with_row_positions(
        params.require(:product).permit(product_properties_attributes: [:id, :property_name, :value, :_destroy]),
        :product_properties
      )
    end
  end
end
