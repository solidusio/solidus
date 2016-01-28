class AddCarrierAndServiceLevelToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :spree_shipping_methods, :carrier, :string
    add_column :spree_shipping_methods, :service_level, :string
  end
end
