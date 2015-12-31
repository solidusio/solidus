class AddCodeToSpreeShippingMethods < ActiveRecord::Migration
  def change
    add_column :solidus_shipping_methods, :code, :string
  end
end
