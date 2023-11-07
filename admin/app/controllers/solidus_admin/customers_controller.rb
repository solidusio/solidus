# frozen_string_literal: true

class SolidusAdmin::CustomersController < SolidusAdmin::BaseController
  before_action :load_order, only: :show

  def show
    render component('orders/show/email').new(order: @order)
  end

  private

  def load_order
    @order = Spree::Order.find_by!(number: params[:order_id])
  end

  def authorization_subject
    @order || Spree::Order
  end
end
