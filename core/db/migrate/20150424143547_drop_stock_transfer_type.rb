class DropStockTransferType < ActiveRecord::Migration[4.2]
  def up
    # type is reserved for Single Table Inheritance
    remove_column :spree_stock_transfers, :type
  end

  def down
    add_column :spree_stock_transfers, :type, :string
  end
end
