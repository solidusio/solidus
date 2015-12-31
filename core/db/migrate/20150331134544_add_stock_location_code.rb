class AddStockLocationCode < ActiveRecord::Migration
  def change
    add_column :solidus_stock_locations, :code, :string
  end
end
