class AddBackorderableToStockItem < ActiveRecord::Migration
  def change
    add_column :solidus_stock_items, :backorderable, :boolean, :default => true
  end
end
