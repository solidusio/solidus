# frozen_string_literal: true

module Spree
  module Admin
    class StockLocationsController < ResourceController
      before_action :set_country, only: :new
      before_action :set_breadcrumbs

      private

      def set_country
        @stock_location.country = Spree::Country.default
      rescue ActiveRecord::RecordNotFound
        flash[:error] = t('spree.stock_locations_need_a_default_country')
        redirect_to(admin_stock_locations_path) && return
      end

      def set_breadcrumbs
        add_breadcrumb t('spree.settings')
        add_breadcrumb t('spree.admin.tab.shipping')
        add_breadcrumb plural_resource_name(Spree::StockLocation), spree.admin_stock_locations_path
        add_breadcrumb @stock_location.name if action_name == 'edit'
        add_breadcrumb t('spree.new_stock_location') if action_name == 'new'
      end
    end
  end
end
