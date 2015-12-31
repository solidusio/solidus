class RenameShippingMethodsZonesToSolidusShippingMethodsZones < ActiveRecord::Migration
  def change
    rename_table :shipping_methods_zones, :solidus_shipping_methods_zones
  end
end
