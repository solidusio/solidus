# frozen_string_literal: true

module Spree
  module Admin
    class CancellationsController < Spree::Admin::BaseController
      before_action :load_order, only: [:index, :short_ship]

      def index
        @inventory_units = @order.inventory_units.cancelable
      end

      def short_ship
        inventory_unit_ids = params[:inventory_unit_ids] || []
        inventory_units = Spree::InventoryUnit.where(id: inventory_unit_ids)

        if inventory_units.size != inventory_unit_ids.size
          flash[:error] = t('spree.unable_to_find_all_inventory_units')
          redirect_to admin_order_cancellations_path(@order)
        elsif inventory_units.empty?
          flash[:error] = t('spree.no_inventory_selected')
          redirect_to admin_order_cancellations_path(@order)
        else
          @order.cancellations.short_ship(inventory_units, created_by: created_by)

          flash[:success] = t('spree.inventory_canceled')
          redirect_to edit_admin_order_url(@order)
        end
      end

      private

      def created_by
        try_spree_current_user.try(:email)
      end

      def load_order
        @order = Spree::Order.find_by!(number: params[:order_id])
        authorize! action, @order
      end

      def model_class
        Spree::OrderCancellations
      end
    end
  end
end
