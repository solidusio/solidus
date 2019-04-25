# frozen_string_literal: true

module Spree
  module Admin
    class RefundReasonsController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.checkout')
        add_breadcrumb plural_resource_name(Spree::RefundReason), spree.admin_refund_reasons_path
        add_breadcrumb @refund_reason.name if action_name == 'edit'
        add_breadcrumb t('spree.new_refund_reason') if action_name == 'new'
      end
    end
  end
end
