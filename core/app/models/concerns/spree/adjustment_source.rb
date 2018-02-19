# frozen_string_literal: true

module Spree
  module AdjustmentSource
    def deals_with_adjustments_for_deleted_source
      Spree::Deprecation.warn "AdjustmentSource#deals_with_adjustments_for_deleted_source is deprecated. Please use AdjustmentSource#remove_adjustments_from_incomplete_orders instead."

      remove_adjustments_from_incomplete_orders

      # The following is deprecated. As source_type without a source_id isn't
      # much better than a source_id that doesn't exist.  In Solidus itself the
      # relevant classes use `acts_as_paranoid` so it is useful to keep the
      # source_id around.
      adjustments.
        joins(:order).
        merge(Spree::Order.complete).
        update_all(source_id: nil, updated_at: Time.current)
    end

    def remove_adjustments_from_incomplete_orders
      adjustments.
        joins(:order).
        merge(Spree::Order.incomplete).
        destroy_all
    end
  end
end
