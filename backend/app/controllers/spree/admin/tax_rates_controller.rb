# frozen_string_literal: true

module Spree
  module Admin
    class TaxRatesController < ResourceController
      before_action :load_data
      before_action :set_breadcrumbs

      private

      def load_data
        @available_zones = Spree::Zone.order(:name)
        @available_categories = Spree::TaxCategory.order(:name)
        @calculators = Rails.application.config.spree.calculators.tax_rates
      end

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.taxes')
        add_breadcrumb plural_resource_name(Spree::TaxRate), spree.admin_tax_rates_path
        add_breadcrumb @tax_rate.name          if action_name == 'edit'
        add_breadcrumb t('spree.new_tax_rate') if action_name == 'new'
      end
    end
  end
end
