class AddForeignKeysForShippingMethodZones < ActiveRecord::Migration
  def change
    add_foreign_key :spree_shipping_method_zones, :spree_shipping_methods,
                    column: :shipping_method_id
    add_foreign_key :spree_shipping_method_zones, :spree_zones, column: :zone_id
  end
end
