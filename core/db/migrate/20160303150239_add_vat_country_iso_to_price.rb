class AddVatCountryIsoToPrice < ActiveRecord::Migration
  def change
    add_column :spree_prices, :vat_country_iso, :string, limit: 2, null: false, default: ''
    add_index :spree_prices, :vat_country_iso
    add_index :spree_countries, :iso
  end
end
