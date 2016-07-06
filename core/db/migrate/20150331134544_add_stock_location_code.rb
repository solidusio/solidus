class AddStockLocationCode < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_stock_locations, :code, :string
  end
end
