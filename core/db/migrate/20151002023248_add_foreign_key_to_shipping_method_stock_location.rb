class AddForeignKeyToShippingMethodStockLocation < ActiveRecord::Migration
  def change
    add_foreign_key :spree_shipping_method_stock_locations, :spree_shipping_methods, column: :shipping_method_id
    add_foreign_key :spree_shipping_method_stock_locations, :spree_stock_locations, column: :stock_location_id
  end
end
