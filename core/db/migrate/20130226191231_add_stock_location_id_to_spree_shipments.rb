class AddStockLocationIdToSolidusShipments < ActiveRecord::Migration
  def change
    add_column :solidus_shipments, :stock_location_id, :integer
  end
end
