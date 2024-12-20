# frozen_string_literal: true

module SolidusAdmin
  class ShippingCategoriesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::ShippingCategory

    def permitted_resource_params
      params.require(:shipping_category).permit(:name)
    end
  end
end
