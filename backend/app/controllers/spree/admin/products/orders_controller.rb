module Spree
  module Admin
    module Products
      class OrdersController < Spree::Admin::BaseController
        before_action :load_product

        def index
          @search = @product.orders.complete.reorder(completed_at: :desc).ransack
          @orders = @search.result(distinct: true)
                           .page(params[:page])
                           .per(params[:per_page] || Spree::Config[:orders_per_page])
          respond_to do |format|
            format.html
          end
        end

        private

        def load_product
          @product = Product.with_deleted.friendly.find(params[:product_id])
        end
      end
    end
  end
end
