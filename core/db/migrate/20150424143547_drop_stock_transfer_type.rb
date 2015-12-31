class DropStockTransferType < ActiveRecord::Migration
  def up
    # type is reserved for Single Table Inheritance
    remove_column :solidus_stock_transfers, :type
  end

  def down
    add_column :solidus_stock_transfers, :type, :string
  end
end
