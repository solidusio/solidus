# frozen_string_literal: true

class OrdersController < StoreController
  helper "spree/products", "orders"

  respond_to :html

  def show
    @order = Spree::Order.find_by!(number: params[:id])
    authorize! :show, @order, params[:token] || cookies.signed[:guest_token]
  end

  private

  def accurate_title
    t("spree.order_number", number: @order.number)
  end
end
