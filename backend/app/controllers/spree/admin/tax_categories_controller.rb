# frozen_string_literal: true

module Spree
  module Admin
    class TaxCategoriesController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.taxes')
        add_breadcrumb plural_resource_name(Spree::TaxCategory), spree.admin_tax_categories_path
        add_breadcrumb @tax_category.name if action_name == 'edit'
        add_breadcrumb t('spree.new_tax_category') if action_name == 'new'
      end
    end
  end
end
