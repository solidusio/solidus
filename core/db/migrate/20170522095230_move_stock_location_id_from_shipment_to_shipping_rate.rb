class MoveStockLocationIdFromShipmentToShippingRate < ActiveRecord::Migration[5.0]
  def up
    add_column :spree_shipping_rates, :stock_location_id, :integer
    execute("UPDATE spree_shipping_rates "\
            "SET stock_location_id=( " \
            "SELECT spree_shipments.stock_location_id " \
            "FROM spree_shipments " \
            "WHERE spree_shipping_rates.shipment_id = spree_shipments.id)"
           )
    rename_column :spree_shipments, :stock_location_id, :deprecated_stock_location_id
  end

  def down
    rename_column :spree_shipments, :deprecated_stock_location_id, :stock_location_id
    execute("UPDATE spree_shipments "\
            "SET stock_location_id=( " \
            "SELECT spree_shipping_rates.stock_location_id " \
            "FROM spree_shipping_rates " \
            "WHERE spree_shipping_rates.shipment_id = spree_shipments.id)"
           )
    drop_column :spree_shipping_rates, :stock_location_id
  end
end
