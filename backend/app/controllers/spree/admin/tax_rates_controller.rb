# frozen_string_literal: true

module Spree
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data

      private

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

