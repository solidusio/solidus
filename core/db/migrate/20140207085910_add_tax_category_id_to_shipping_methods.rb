class AddTaxCategoryIdToShippingMethods < ActiveRecord::Migration
  def change
    add_column :solidus_shipping_methods, :tax_category_id, :integer
  end
end
