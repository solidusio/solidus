class RenameActivatorTranslationsToPromotionTranslations < ActiveRecord::Migration
  def change
    if ActiveRecord::Base.connection.table_exists? 'spree_activator_translations'
      rename_table :spree_activator_translations, :spree_promotion_translations
      rename_column :spree_promotion_translations, :spree_activator_id, :spree_promotion_id
    end
  end
end
