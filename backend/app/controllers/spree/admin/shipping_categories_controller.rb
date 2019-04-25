# frozen_string_literal: true

module Spree
  module Admin
    class ShippingCategoriesController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.shipping')
        add_breadcrumb plural_resource_name(Spree::ShippingCategory), spree.admin_shipping_categories_path
        add_breadcrumb t('spree.editing_shipping_category') if action_name == 'edit'
        add_breadcrumb t('spree.new_shipping_category') if action_name == 'new'
      end
    end
  end
end
