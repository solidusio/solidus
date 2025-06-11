# frozen_string_literal: true

module SolidusAdmin
  class TaxCategoriesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::TaxCategory

    def permitted_resource_params
      params.require(:tax_category).permit(:name, :description, :is_default, :tax_code, :tax_reverse_charge_mode)
    end
  end
end
