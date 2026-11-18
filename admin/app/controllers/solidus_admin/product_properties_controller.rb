# frozen_string_literal: true

module SolidusAdmin
  class ProductPropertiesController < SolidusAdmin::BaseController
    before_action :load_product

    def new
      @product_property = @product.product_properties.build

      respond_to do |format|
        format.turbo_stream
      end
    end

    def edit
      respond_to do |format|
        format.html { render form_component }
      end
    end

    def update
      if @product.update(product_properties_params)
        flash[:notice] = t(".success")

        respond_to do |format|
          format.html { redirect_to solidus_admin.product_path(@product), status: :see_other }
          format.turbo_stream
        end
      else
        respond_to do |format|
          format.html { render form_component, status: :unprocessable_entity }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(:specifications_modal, form_component),
              status: :unprocessable_entity
          end
        end
      end
    end

    private

    def product_properties_params
      params.require(:product).permit(product_properties_attributes: [:id, :property_name, :value, :_destroy])
    end

    def load_product
      @product = Spree::Product.friendly.find(params[:product_id])
    end

    def form_component
      component("products/show/specifications/form").new(product: @product)
    end
  end
end
