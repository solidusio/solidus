class AddAddressFormatSettingsToCountries < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_countries, :provence_label, :string
    add_column :spree_countries, :provence_specified, :integer, limit: 1
    add_column :spree_countries, :postal_label, :string
    add_column :spree_countries, :postal_position, :integer, limit: 1
    add_column :spree_countries, :postal_specified, :integer, limit: 1
  end
end
