class CreateSpreeShippingMethodStockLocations < ActiveRecord::Migration
  def change
    create_table :spree_shipping_method_stock_locations do |t|
      t.belongs_to :shipping_method
      t.belongs_to :stock_location

      t.timestamps null: true
    end

    add_index :spree_shipping_method_stock_locations, :shipping_method_id, name: "shipping_method_id_spree_sm_sl"
    add_index :spree_shipping_method_stock_locations, :stock_location_id, name: "sstock_location_id_spree_sm_sl"
  end
end
