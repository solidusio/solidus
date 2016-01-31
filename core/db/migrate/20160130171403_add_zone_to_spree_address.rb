class AddZoneToSpreeAddress < ActiveRecord::Migration
  def change
    add_reference :spree_addresses, :zone, index: true
    add_foreign_key :spree_addresses, :spree_zones, column: :zone_id
  end
end
