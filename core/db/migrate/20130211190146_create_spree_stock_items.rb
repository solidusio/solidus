class CreateSpreeStockItems < ActiveRecord::Migration
  def change
    create_table :solidus_stock_items do |t|
      t.belongs_to :stock_location
      t.belongs_to :variant
      t.integer :count_on_hand, null: false, default: 0
      t.integer :lock_version

      t.timestamps null: true
    end
    add_index :solidus_stock_items, :stock_location_id
    add_index :solidus_stock_items, [:stock_location_id, :variant_id], :name => 'stock_item_by_loc_and_var_id'
  end
end
