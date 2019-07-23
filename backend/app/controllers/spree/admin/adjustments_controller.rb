# frozen_string_literal: true

module Spree
  module Admin
    class AdjustmentsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      create.after :update_totals
      destroy.after :update_totals
      update.after :update_totals

      skip_before_action :load_resource, only: [:toggle_state, :edit, :update, :destroy]

      before_action :find_adjustment, only: [:destroy, :edit, :update]
      before_action :set_breadcrumbs

      helper_method :reasons_for

      def index
        @adjustments = @order.all_adjustments.order("created_at ASC")
      end

      private

      def find_adjustment
        # Need to assign to @object here to keep ResourceController happy
        @adjustment = @object = parent.all_adjustments.find(params[:id])
      end

      def update_totals
        @order.reload.recalculate
      end

      # Override method used to create a new instance to correctly
      # associate adjustment with order
      def build_resource
        parent.adjustments.build(order: parent)
      end

      def reasons_for(_adjustment)
        [
          Spree::AdjustmentReason.active.to_a,
          @adjustment.adjustment_reason
        ].flatten.compact.uniq.sort_by { |r| r.name.downcase }
      end

      def set_breadcrumbs
        set_order_breadcrumbs
        add_breadcrumb plural_resource_name(Spree::Adjustment), spree.admin_order_adjustments_path(@order)
        add_breadcrumb t('spree.new_adjustment') if action_name == 'new'
        add_breadcrumb "#{t('spree.actions.edit')} #{Spree::Adjustment.model_name.human}" if action_name == 'edit'
      end
    end
  end
end
