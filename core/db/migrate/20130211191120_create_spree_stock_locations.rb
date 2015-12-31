class CreateSolidusStockLocations < ActiveRecord::Migration
  def change
    create_table :solidus_stock_locations do |t|
      t.string :name
      t.belongs_to :address

      t.timestamps null: true
    end
    add_index :solidus_stock_locations, :address_id
  end
end
