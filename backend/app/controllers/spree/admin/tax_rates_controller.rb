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
    end
  end
end
