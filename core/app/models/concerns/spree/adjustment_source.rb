# frozen_string_literal: true

module Spree
  module AdjustmentSource
    def remove_adjustments_from_incomplete_orders
      adjustments.
        joins(:order).
        merge(Spree::Order.incomplete).
        destroy_all
    end
  end
end

