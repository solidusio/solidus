class RemoveExtraProductsSlugIndex < ActiveRecord::Migration
  def change
    remove_index :solidus_products, name: :permalink_idx_unique
  end
end
