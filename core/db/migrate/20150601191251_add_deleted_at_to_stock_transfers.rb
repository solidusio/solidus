class AddDeletedAtToStockTransfers < ActiveRecord::Migration
  def change
    add_column :solidus_stock_transfers, :deleted_at, :datetime
  end
end
