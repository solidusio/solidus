class AddOrderIdsToAdjustmentsWhereMissing < ActiveRecord::Migration[4.2]
  def up
    Spree::Adjustment.where(order_id: nil, adjustable_type: 'Spree::Order').update_all("order_id = adjustable_id")
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
