# frozen_string_literal: true

module Spree
  module Admin
    class StockLocationsController < ResourceController
      before_action :set_country, only: :new

      private

      def set_country
        @stock_location.country = Spree::Country.default
      rescue ActiveRecord::RecordNotFound
        flash[:error] = t('spree.stock_locations_need_a_default_country')
        redirect_to(admin_stock_locations_path) && return
      end
    end
  end
end
