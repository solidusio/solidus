class RemoveDefaultTaxFromZones < ActiveRecord::Migration[5.0]
  class DefaultTaxZonePresent < StandardError; end
  def change
    if Spree::Zone.where(default_tax: true).any?
      raise DefaultTaxZonePresent, "Please run the the solidus:migrations:create_vat_prices rake task."
    end
    remove_column :spree_zones, :default_tax, :boolean, default: false
  end
end
