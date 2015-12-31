class AddOrderIdIndexToShipments < ActiveRecord::Migration
  def change
    add_index :solidus_shipments, :order_id
  end
end
