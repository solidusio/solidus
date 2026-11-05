# frozen_string_literal: true

module Spree
  module Admin
    class ShippingCategoriesController < ResourceController
      private

      def permitted_resource_params
        params.require(:shipping_category).permit(:name)
      end
    end
  end
end
