class AddBackorderableDefaultToSolidusStockLocation < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :backorderable_default, :boolean, default: true
  end
end
