module Spree
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data

      private

      def load_data
        @available_zones = Zone.order(:name)
        @available_categories = TaxCategory.order(:name)
        @calculators = Rails.application.config.spree.calculators.tax_rates
      end
    end
  end
end
