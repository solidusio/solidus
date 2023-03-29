class AddShippingCategoryToSpreeVariants < Spree::Migration
  def change
    add_reference :spree_variants, :shipping_category, index: true
  end
end
