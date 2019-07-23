# frozen_string_literal: true

module Spree
  module Admin
    class ReimbursementTypesController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.checkout')
        add_breadcrumb plural_resource_name(Spree::ReimbursementType)
      end
    end
  end
end
