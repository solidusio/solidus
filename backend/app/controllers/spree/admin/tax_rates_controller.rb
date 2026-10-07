# frozen_string_literal: true

module Spree
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data

      private

      def permitted_resource_params
        params.require(:tax_rate).permit(
          :name, :amount, :included_in_price, :level, :zone_id, :show_rate_in_label,
          :starts_at, :expires_at, :calculator_type,
          tax_category_ids: [],
          calculator_attributes: [:id, *calculator_attributes]
        )
      end

      def calculator_attributes
        @calculators.flat_map do |calculator_class|
          calculator_class.permitted_preference_attributes
        end
      end

      def load_data
        @available_zones = Spree::Zone.order(:name)
        @available_categories = Spree::TaxCategory.order(:name)
        @calculators = Rails.application.config.spree.calculators.tax_rates
      end

      def collection
        @search = Spree::TaxRate.ransack(params[:q])
        @collection = @search.result
        @collection = @collection
          .includes(:tax_categories)
          .order(:zone_id)
        @collection = @collection
          .page(params[:page])
          .per(Spree::Config[:admin_products_per_page])
      end
    end
  end
end
