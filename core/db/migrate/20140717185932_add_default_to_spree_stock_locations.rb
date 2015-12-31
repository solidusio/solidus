class AddDefaultToSolidusStockLocations < ActiveRecord::Migration
  def change
    unless column_exists? :solidus_stock_locations, :default
      add_column :solidus_stock_locations, :default, :boolean, null: false, default: false
    end
  end
end
