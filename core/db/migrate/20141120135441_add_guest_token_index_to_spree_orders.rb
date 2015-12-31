class AddGuestTokenIndexToSolidusOrders < ActiveRecord::Migration
  def change
    add_index :solidus_orders, :guest_token
  end
end
