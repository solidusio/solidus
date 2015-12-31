class AddPendingToInventoryUnit < ActiveRecord::Migration
  def change
    add_column :spree_inventory_units, :pending, :boolean, :default => true
    Solidus::InventoryUnit.update_all(:pending => false)
  end
end
