class CreateStockMovements < ActiveRecord::Migration
  def change
    create_table :solidus_stock_movements do |t|
      t.belongs_to :stock_item
      t.integer :quantity
      t.string :action

      t.timestamps null: false
    end
    add_index :solidus_stock_movements, :stock_item_id
  end
end
