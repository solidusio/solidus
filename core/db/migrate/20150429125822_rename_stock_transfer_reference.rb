class RenameStockTransferReference < ActiveRecord::Migration
  def change
    rename_column :spree_stock_transfers, :reference, :description
  end
end
