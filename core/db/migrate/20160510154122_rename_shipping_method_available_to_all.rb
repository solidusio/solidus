class RenameShippingMethodAvailableToAll < ActiveRecord::Migration
  def change
    rename_column :spree_shipping_methods, :available_to_all, :available_to_all_stock_locations
  end
end
