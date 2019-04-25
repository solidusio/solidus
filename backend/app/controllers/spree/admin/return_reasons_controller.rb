# frozen_string_literal: true

module Spree
  module Admin
    class ReturnReasonsController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.checkout')
        add_breadcrumb plural_resource_name(Spree::ReturnReason), spree.admin_return_reasons_path
        add_breadcrumb t('spree.new_rma_reason') if action_name == 'new'
        add_breadcrumb @object.name if action_name == 'edit'
      end
    end
  end
end
