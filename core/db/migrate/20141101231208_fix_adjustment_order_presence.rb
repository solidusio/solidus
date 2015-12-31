class FixAdjustmentOrderPresence < ActiveRecord::Migration
  def change
    say 'Fixing adjustments without direct order reference'
    Solidus::Adjustment.where(order: nil).find_each do |adjustment|
      adjustable = adjustment.adjustable
      if adjustable.is_a? Solidus::Order
        adjustment.update_attributes!(order_id: adjustable.id)
      else
        adjustment.update_attributes!(order_id: adjustable.order.id)
      end
    end
  end
end
