module Spree
  module Admin
    class StockLocationsController < ResourceController

      before_action :set_country, only: :new

      private

      def set_country
        begin
          if Solidus::Config[:default_country_id].present?
            @stock_location.country = Solidus::Country.find(Solidus::Config[:default_country_id])
          else
            @stock_location.country = Solidus::Country.find_by!(iso: 'US')
          end

        rescue ActiveRecord::RecordNotFound
          flash[:error] = Spree.t(:stock_locations_need_a_default_country)
          redirect_to admin_stock_locations_path and return
        end
      end

    end
  end
end
