class AddShippingCategoryToSpreeVariants < ActiveRecord::Migration[5.2]
  def change
    add_reference :spree_variants, :shipping_category, index: true
  end
end
