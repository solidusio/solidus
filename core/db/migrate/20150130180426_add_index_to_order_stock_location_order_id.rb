class AddIndexToOrderStockLocationOrderId < ActiveRecord::Migration
  def change
    add_index :spree_order_stock_locations, :order_id
  end
end
