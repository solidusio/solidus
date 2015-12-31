class RenameStockTransferReference < ActiveRecord::Migration
  def change
    rename_column :solidus_stock_transfers, :reference, :description
  end
end
