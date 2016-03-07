module Spree
  module AdjustmentSource
    def deals_with_adjustments_for_deleted_source
      adjustment_scope = adjustments.joins(:order)

      # For incomplete orders, remove the adjustment completely.
      adjustment_scope.where(spree_orders: { completed_at: nil }).destroy_all

      # For complete orders, the source will be invalid.
      # Therefore we nullify the source_id, leaving the adjustment in place.
      # This would mean that the order's total is not altered at all.
      attrs = {
        source_id: nil,
        updated_at: Time.current
      }
      adjustment_scope.where.not(spree_orders: { completed_at: nil }).update_all(attrs)
    end
  end
end
