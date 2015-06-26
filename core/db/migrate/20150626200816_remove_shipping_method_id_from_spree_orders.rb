class RemoveShippingMethodIdFromSpreeOrders < ActiveRecord::Migration
  def up
    remove_column :spree_orders, :shipping_method_id, :integer
  end

  def down
    add_column :spree_orders, :shipping_method_id, :integer
  end
end
