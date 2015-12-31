class AddDeletedAtToSpreeStockItems < ActiveRecord::Migration
  def change
    add_column :solidus_stock_items, :deleted_at, :datetime
  end
end
