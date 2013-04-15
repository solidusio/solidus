class AddTranslationsToProducts < ActiveRecord::Migration
  def up
    params = { :name => :string,
               :description => :text,
               :meta_description => :string,
               :meta_keywords => :string }
    Spree::Product.create_translation_table!(params, { :migrate_data => true })
  end

  def down
    Spree::Product.drop_translation_table! :migrate_data => true
  end
end
