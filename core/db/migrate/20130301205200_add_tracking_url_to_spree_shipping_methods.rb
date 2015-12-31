class AddTrackingUrlToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :solidus_shipping_methods, :tracking_url, :string
  end
end
