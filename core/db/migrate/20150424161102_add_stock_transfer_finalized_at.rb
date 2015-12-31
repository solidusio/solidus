class AddStockTransferFinalizedAt < ActiveRecord::Migration
  def change
    add_column :solidus_stock_transfers, :finalized_at, :datetime
    add_column :solidus_stock_transfers, :finalized_by_id, :integer

    add_index :solidus_stock_transfers, :finalized_at
  end
end
