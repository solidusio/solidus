class RenameStockTransferReference < ActiveRecord::Migration[4.2]
  def change
    rename_column :spree_stock_transfers, :reference, :description
  end
end
