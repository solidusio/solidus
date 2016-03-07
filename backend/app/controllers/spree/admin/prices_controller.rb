module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      private

      def collection
        params[:q] ||= {}

        @search = super.ransack(params[:q])
        @collection = @search.result.page(params[:page]).per(20)
      end
    end
  end
end
