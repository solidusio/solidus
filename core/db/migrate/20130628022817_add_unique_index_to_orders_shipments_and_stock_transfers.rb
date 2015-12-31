class AddUniqueIndexToOrdersShipmentsAndStockTransfers < ActiveRecord::Migration
  def add
    add_index "solidus_orders", ["number"], :name => "number_idx_unique", :unique => true
    add_index "solidus_shipments", ["number"], :name => "number_idx_unique", :unique => true
    add_index "solidus_stock_transfers", ["number"], :name => "number_idx_unique", :unique => true
  end
end
