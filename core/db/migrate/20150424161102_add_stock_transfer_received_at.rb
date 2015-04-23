class AddStockTransferReceivedAt < ActiveRecord::Migration
  def change
    add_column :spree_stock_transfers, :received_at, :datetime
    add_column :spree_stock_transfers, :received_by_id, :integer

    add_index :spree_stock_transfers, :received_at
  end
end
