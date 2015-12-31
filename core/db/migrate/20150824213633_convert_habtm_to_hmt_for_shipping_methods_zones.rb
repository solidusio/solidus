class ConvertHabtmToHmtForShippingMethodsZones < ActiveRecord::Migration
  def up
    add_column :solidus_shipping_methods_zones, :id, :primary_key
    add_column :solidus_shipping_methods_zones, :created_at, :datetime
    add_column :solidus_shipping_methods_zones, :updated_at, :datetime

    rename_table :solidus_shipping_methods_zones, :solidus_shipping_method_zones
  end

  def down
    rename_table :solidus_shipping_method_zones, :solidus_shipping_methods_zones

    remove_column :solidus_shipping_methods_zones, :updated_at
    remove_column :solidus_shipping_methods_zones, :created_at
    remove_column :solidus_shipping_methods_zones, :id
  end
end
