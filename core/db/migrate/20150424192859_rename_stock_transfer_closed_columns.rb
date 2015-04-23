class RenameStockTransferClosedColumns < ActiveRecord::Migration
  def change
    rename_column :spree_stock_transfers, :closed_at, :submitted_at
    rename_column :spree_stock_transfers, :closed_by_id, :submitted_by_id
  end
end
