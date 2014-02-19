class UpdateSpreeProductTranslations < ActiveRecord::Migration
  def change
    if column_exists?(:spree_product_translations, :permalink)
      rename_column :spree_product_translations, :permalink, :slug
    end
  end
end
