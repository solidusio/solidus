class AddIndexToInventoryUnitsCartonId < ActiveRecord::Migration
  def change
    add_index :solidus_inventory_units, :carton_id
  end
end
