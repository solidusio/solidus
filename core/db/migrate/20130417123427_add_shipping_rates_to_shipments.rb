class AddShippingRatesToShipments < ActiveRecord::Migration
  def up
    Solidus::Shipment.find_each do |shipment|
      shipment.shipping_rates.create(:shipping_method_id => shipment.shipping_method_id,
                                     :cost => shipment.cost,
                                     :selected => true)
    end

    remove_column :solidus_shipments, :shipping_method_id
  end

  def down
    add_column :solidus_shipments, :shipping_method_id, :integer
  end
end
