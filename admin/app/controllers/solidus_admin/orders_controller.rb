# frozen_string_literal: true

module SolidusAdmin
  class OrdersController < SolidusAdmin::BaseController
    def index
      orders = Spree::Order
        .order(created_at: :desc, id: :desc)
        .ransack(params[:q])
        .result(distinct: true)

      set_page_and_extract_portion_from(
        orders,
        per_page: SolidusAdmin::Config[:orders_per_page]
      )

      respond_to do |format|
        format.html { render component('orders/index').new(page: @page) }
      end
    end
  end
end
