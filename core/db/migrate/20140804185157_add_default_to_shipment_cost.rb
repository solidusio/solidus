class AddDefaultToShipmentCost < ActiveRecord::Migration
  def up
    change_column :solidus_shipments, :cost, :decimal, precision: 10, scale: 2, default: 0.0
    Solidus::Shipment.where(cost: nil).update_all(cost: 0)
  end

  def down
    change_column :solidus_shipments, :cost, :decimal, precision: 10, scale: 2
  end
end
