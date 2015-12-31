class AddAdminNameColumnToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :solidus_shipping_methods, :admin_name, :string
  end
end
