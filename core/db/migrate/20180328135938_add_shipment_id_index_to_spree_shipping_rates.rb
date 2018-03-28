class AddShipmentIdIndexToSpreeShippingRates < ActiveRecord::Migration[5.0]
  def change
    add_index :spree_shipping_rates, :shipment_id
  end
end
