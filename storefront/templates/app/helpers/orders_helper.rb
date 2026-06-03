# frozen_string_literal: true

module OrdersHelper
  def order_just_completed?(order)
    flash[:order_completed] && order.present?
  end
end
