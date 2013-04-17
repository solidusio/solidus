class AddTranslationsToTaxons < ActiveRecord::Migration
  def up
    params = { :name => :string,
               :description => :text,
               :meta_title => :string,
               :meta_description => :string,
               :meta_keywords => :string }
    Spree::Taxon.create_translation_table!(params, { :migrate_data => true })
  end

  def down
    Spree::Taxon.drop_translation_table! :migrate_data => true
  end
end
