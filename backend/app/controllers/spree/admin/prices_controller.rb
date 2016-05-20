module Spree
  module Admin
    class PricesController < ResourceController
      belongs_to 'spree/product', find_by: :slug

      def index
        params[:q] ||= {}

        @search = @product.prices.accessible_by(current_ability, :index).ransack(params[:q])
        @prices = @search.result.page(params[:page]).per(10)
      end

      def edit
      end
    end
  end
end
