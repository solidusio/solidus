class AddSkuIndexToSpreeVariants < ActiveRecord::Migration
  def change
    add_index :solidus_variants, :sku
  end
end
