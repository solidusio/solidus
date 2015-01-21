class AddRestockInventoryToStockLocation < ActiveRecord::Migration
  def change
    add_column :spree_stock_locations, :restock_inventory, :boolean, default: true, null: false
  end
end
