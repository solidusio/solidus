class AddTokenToSolidusOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :guest_token, :string
  end
end
