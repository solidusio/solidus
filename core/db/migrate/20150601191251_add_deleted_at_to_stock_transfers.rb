class AddDeletedAtToStockTransfers < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_stock_transfers, :deleted_at, :datetime
  end
end
