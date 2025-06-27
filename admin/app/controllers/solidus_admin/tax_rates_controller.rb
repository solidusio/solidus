# frozen_string_literal: true

module SolidusAdmin
  class TaxRatesController < SolidusAdmin::ResourcesController
    private

    def resource_class = Spree::TaxRate

    def resources_collection
      resource_class.includes(:zone, :tax_categories, :calculator)
    end

    def resources_sorting_options = { created_at: :desc, id: :desc }

    def permitted_resource_params
      params.require(:tax_rate).permit(:name, :zone_id, :show_rate_in_label, :calculator_type, :amount, :level,
        :included_in_price, :starts_at, :expires_at, tax_category_ids: [])
    end
  end
end
