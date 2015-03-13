class AddImportedFromShipmentIdToCartons < ActiveRecord::Migration
  def change
    # Temporarily add this column until we're sure that this migration and the
    # upcoming code changes are working correctly
    add_column :spree_cartons, :imported_from_shipment_id, :integer
    add_index :spree_cartons, :imported_from_shipment_id, unique: true
  end
end
