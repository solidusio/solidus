class AddTranslationsForPromotions < ActiveRecord::Migration
  def up
    params = { :name => :string, :description => :text }
    Spree::Promotion.create_translation_table!(params, { :migrate_data => true })
  end

  def down
    Spree::Promotion.drop_translation_table! :migrate_data => true
  end
end
