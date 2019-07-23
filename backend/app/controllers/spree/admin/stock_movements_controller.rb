# frozen_string_literal: true

module Spree
  module Admin
    class StockMovementsController < ResourceController
      belongs_to 'spree/stock_location'
      before_action :parent
      before_action :set_breadcrumbs

      private

      def permitted_resource_params
        params.require(:stock_movement).permit(:quantity, :stock_item_id, :action)
      end

      def collection
        super.
          recent.
          includes(stock_item: { variant: :product }).
          page(params[:page])
      end

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.shipping')
        if can?(:display, Spree::StockLocation)
          add_breadcrumb plural_resource_name(Spree::StockLocation), spree.admin_stock_locations_path
        else
          add_breadcrumb plural_resource_name(Spree::StockLocation)
        end
        if can?(:update, @stock_location)
          add_breadcrumb helpers.admin_stock_location_display_name(@stock_location), spree.edit_admin_stock_location_path(@stock_location.id)
        else
          add_breadcrumb helpers.admin_stock_location_display_name(@stock_location)
        end
        add_breadcrumb plural_resource_name(Spree::StockMovement)
      end
    end
  end
end
