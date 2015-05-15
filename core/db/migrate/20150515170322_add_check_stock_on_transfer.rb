class AddCheckStockOnTransfer < ActiveRecord::Migration
  def change
    add_column :spree_stock_locations, :check_stock_on_transfer, :boolean, default: true
  end
end
