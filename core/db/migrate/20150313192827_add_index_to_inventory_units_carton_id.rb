class AddIndexToInventoryUnitsCartonId < ActiveRecord::Migration
  def change
    add_index :spree_inventory_units, :carton_id
  end
end
