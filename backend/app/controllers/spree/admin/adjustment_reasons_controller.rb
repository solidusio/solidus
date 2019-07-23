# frozen_string_literal: true

module Spree
  module Admin
    class AdjustmentReasonsController < ResourceController
      before_action :set_breadcrumbs

      private

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.checkout')
        add_breadcrumb plural_resource_name(Spree::AdjustmentReason), spree.admin_adjustment_reasons_path
        add_breadcrumb @adjustment_reason.name if params[:id].present?
        add_breadcrumb t('spree.new_adjustment_reason') if action_name == 'new'
      end
    end
  end
end
