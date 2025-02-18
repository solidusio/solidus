# frozen_string_literal: true

class SolidusAdmin::CustomersController < SolidusAdmin::BaseController
  before_action :load_order, only: [:show, :destroy]

  def show
    respond_to do |format|
      format.html do
        render component("orders/show/email").new(order: @order)
      end
    end
  end

  def destroy
    if @order.update(user: nil)
      flash[:success] = t(".success")
    else
      flash[:error] = t(".error")
    end

    redirect_to order_path(@order), status: :see_other
  end

  private

  def load_order
    @order = Spree::Order.find_by!(number: params[:order_id])
  end

  def authorization_subject
    @order || Spree::Order
  end
end
