class RemoveDefaultTaxFromZones < ActiveRecord::Migration
  def up
    say "Please make sure your default country ISO code is set correctly. Your default zone will otherwise be wrong."
    remove_column :spree_zones, :default_tax, :boolean
  end

  def down
    say "Please set the default tax boolean correctly!"
    add_column :spree_zones, :default_tax, :boolean
  end
end
