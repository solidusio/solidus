class AddLastIpToSolidusOrders < ActiveRecord::Migration
  def change
    add_column :solidus_orders, :last_ip_address, :string
  end
end
