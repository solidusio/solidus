class AddStockLocationCode < ActiveRecord::Migration
  def change
    add_column :spree_stock_locations, :code, :string
  end
end
