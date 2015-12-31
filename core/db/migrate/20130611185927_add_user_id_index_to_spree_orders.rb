class AddUserIdIndexToSolidusOrders < ActiveRecord::Migration
  def change
    add_index :solidus_orders, :user_id
  end
end
