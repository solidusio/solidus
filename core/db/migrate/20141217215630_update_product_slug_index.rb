class UpdateProductSlugIndex < ActiveRecord::Migration
  def change
    remove_index :solidus_products, :slug
    add_index :solidus_products, :slug, unique: true
  end
end
