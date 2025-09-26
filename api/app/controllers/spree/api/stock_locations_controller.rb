# frozen_string_literal: true

module Spree
  module Api
    class StockLocationsController < Spree::Api::BaseController
      def index
        authorize! :index, StockLocation

        @stock_locations = StockLocation
          .accessible_by(current_ability)
          .order("name ASC")
          .ransack(params[:q])
          .result

        @stock_locations = paginate(@stock_locations)

        respond_with(@stock_locations)
      end

      def show
        respond_with(stock_location)
      end

      def create
        authorize! :create, StockLocation
        @stock_location = Spree::StockLocation.new(stock_location_params)
        if @stock_location.save
          respond_with(@stock_location, status: 201, default_template: :show)
        else
          invalid_resource!(@stock_location)
        end
      end

      def update
        authorize! :update, stock_location
        if stock_location.update(stock_location_params)
          respond_with(stock_location, status: 200, default_template: :show)
        else
          invalid_resource!(stock_location)
        end
      end

      def destroy
        authorize! :destroy, stock_location
        stock_location.destroy
        respond_with(stock_location, status: 204)
      end

      private

      def stock_location
        @stock_location ||= Spree::StockLocation.accessible_by(current_ability, :show).find(params[:id])
      end

      def stock_location_params
        params.require(:stock_location).permit(permitted_stock_location_attributes)
      end
    end
  end
end
