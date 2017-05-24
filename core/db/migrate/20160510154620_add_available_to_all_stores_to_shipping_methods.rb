class AddAvailableToAllStoresToShippingMethods < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :available_to_all_stores, :boolean, default: true
  end
end
