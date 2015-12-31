class AddExchangeInventoryUnitForeignKeys < ActiveRecord::Migration
  def change
    add_column :solidus_return_items, :exchange_inventory_unit_id, :integer

    add_index :solidus_return_items, :exchange_inventory_unit_id
  end
end
