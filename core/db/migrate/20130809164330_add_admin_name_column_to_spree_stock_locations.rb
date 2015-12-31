class AddAdminNameColumnToSolidusStockLocations < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :admin_name, :string
  end
end
