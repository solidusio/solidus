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

    def new
      @order = Spree::Order.new(
        created_by: current_solidus_admin_user,
        frontend_viewable: false,
        store_id: current_store.try(:id)
      )

      respond_to do |format|
        format.html { render component('orders/new').new(order: @order) }
      end
    end
  end
end
