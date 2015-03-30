class CreateSpreeUserStockLocations < ActiveRecord::Migration
  def change
    create_table :spree_user_stock_locations do |t|
      t.integer :user_id
      t.integer :stock_location_id
      t.timestamps
    end
    add_index :spree_user_stock_locations, :user_id
  end
end
