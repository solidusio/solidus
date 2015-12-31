class IndexCompletedAtOnSolidusOrders < ActiveRecord::Migration
  def change
    add_index :solidus_orders, :completed_at
  end
end
