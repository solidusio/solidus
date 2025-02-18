# frozen_string_literal: true

module Spree
  module Admin
    class StockMovementsController < ResourceController
      belongs_to "spree/stock_location"
      before_action :parent

      def index
        params[:q] ||= {}

        @search = collection.ransack(params[:q])
        @stock_movements = @search.result.page(params[:page])
      end

      private

      def permitted_resource_params
        params.require(:stock_movement).permit(:quantity, :stock_item_id, :action)
      end

      def collection
        super
          .recent
          .includes(stock_item: {variant: :product})
          .page(params[:page])
      end
    end
  end
end
