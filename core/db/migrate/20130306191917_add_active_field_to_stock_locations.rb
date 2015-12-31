class AddActiveFieldToStockLocations < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :active, :boolean, :default => true
  end
end
