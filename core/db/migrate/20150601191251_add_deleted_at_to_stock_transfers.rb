class AddDeletedAtToStockTransfers < ActiveRecord::Migration
  def change
    add_column :spree_stock_transfers, :deleted_at, :datetime
  end
end
