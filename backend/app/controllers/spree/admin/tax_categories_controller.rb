# frozen_string_literal: true

module Spree
  module Admin
    class TaxCategoriesController < ResourceController
      private

      def permitted_resource_params
        params.require(:tax_category).permit(:name, :description, :is_default, :tax_code)
      end
    end
  end
end
