class RenameReturnAuthorizationInventoryUnitToReturnItems < ActiveRecord::Migration
  def change
    rename_table :solidus_return_authorization_inventory_units, :solidus_return_items
  end
end
