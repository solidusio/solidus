class AddOrderIdsToAdjustmentsWhereMissing < ActiveRecord::Migration
  def up
    Solidus::Adjustment.where(order_id: nil, adjustable_type: 'Solidus::Order').update_all("order_id = adjustable_id")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
