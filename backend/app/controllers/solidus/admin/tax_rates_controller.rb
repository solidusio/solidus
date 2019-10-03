# frozen_string_literal: true

module Solidus
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data

      private

      def load_data
        @available_zones = Solidus::Zone.order(:name)
        @available_categories = Solidus::TaxCategory.order(:name)
        @calculators = Rails.application.config.spree.calculators.tax_rates
      end
    end
  end
end
