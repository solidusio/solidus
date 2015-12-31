class AddAddressFieldsToStockLocation < ActiveRecord::Migration
  def change
    remove_column :solidus_stock_locations, :address_id

    add_column :solidus_stock_locations, :address1, :string
    add_column :solidus_stock_locations, :address2, :string
    add_column :solidus_stock_locations, :city, :string
    add_column :solidus_stock_locations, :state_id, :integer
    add_column :solidus_stock_locations, :state_name, :string
    add_column :solidus_stock_locations, :country_id, :integer
    add_column :solidus_stock_locations, :zipcode, :string
    add_column :solidus_stock_locations, :phone, :string


    usa = Solidus::Country.where(:iso => 'US').first
    # In case USA isn't found.
    # See #3115
    country = usa || Solidus::Country.first
    Solidus::Country.reset_column_information
    Solidus::StockLocation.update_all(:country_id => country)
  end
end
