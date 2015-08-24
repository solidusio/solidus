class ConvertHabtmToHmtForShippingMethodsZones < ActiveRecord::Migration
  def up
    add_column :spree_shipping_methods_zones, :id, :primary_key
    add_column :spree_shipping_methods_zones, :created_at, :datetime
    add_column :spree_shipping_methods_zones, :updated_at, :datetime

    rename_table :spree_shipping_methods_zones, :spree_shipping_method_zones
  end

  def down
    rename_table :spree_shipping_method_zones, :spree_shipping_methods_zones

    remove_column :spree_shipping_methods_zones, :updated_at
    remove_column :spree_shipping_methods_zones, :created_at
    remove_column :spree_shipping_methods_zones, :id
  end
end
