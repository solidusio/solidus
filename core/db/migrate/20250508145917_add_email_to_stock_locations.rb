class AddEmailToStockLocations < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stock_locations, :email, :string
  end
end
