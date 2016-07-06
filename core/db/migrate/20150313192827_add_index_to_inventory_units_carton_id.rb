class AddIndexToInventoryUnitsCartonId < ActiveRecord::Migration[4.2]
  def change
    add_index :spree_inventory_units, :carton_id
  end
end
