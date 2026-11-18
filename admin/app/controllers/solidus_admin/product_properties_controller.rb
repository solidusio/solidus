# frozen_string_literal: true

module SolidusAdmin
  class ProductPropertiesController < SolidusAdmin::BaseController
    include SolidusAdmin::ProductSpecifications

    def new
      @product_property = @product.product_properties.build(position: next_position)

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

    def next_position
      @product.product_properties.maximum(:position).to_i + 1
    end

    def product_properties_params
      params.require(:product).permit(product_properties_attributes: [:id, :property_name, :value, :position, :_destroy])
    end
  end
end
