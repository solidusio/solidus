# frozen_string_literal: true

module Spree
  module UserReporting
    extend DisplayMoney

    money_methods :lifetime_value, :average_order_value

    def lifetime_value
      spree_orders.complete.pluck(:total).sum
    end

    def order_count
      spree_orders.complete.count
    end

    def average_order_value
      if order_count.to_i > 0
        lifetime_value / order_count
      else
        Spree::ZERO
      end
    end
  end
end
