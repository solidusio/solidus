class AddCountryIsoToPrices < ActiveRecord::Migration
  def change
    add_column :spree_prices, :country_iso, :string, null: true, limit: 2

    add_index :spree_prices, :country_iso
    add_index :spree_countries, :iso
  end
end
