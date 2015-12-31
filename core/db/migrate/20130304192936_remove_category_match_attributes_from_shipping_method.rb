class RemoveCategoryMatchAttributesFromShippingMethod < ActiveRecord::Migration
  def change
    remove_column :solidus_shipping_methods, :match_none
    remove_column :solidus_shipping_methods, :match_one
    remove_column :solidus_shipping_methods, :match_all
  end
end
