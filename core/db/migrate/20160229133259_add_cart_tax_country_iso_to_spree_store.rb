class AddCartTaxCountryIsoToSpreeStore < ActiveRecord::Migration
  def change
    add_column :spree_stores, :cart_tax_country_iso, :string, null: true, default: nil
  end
end
