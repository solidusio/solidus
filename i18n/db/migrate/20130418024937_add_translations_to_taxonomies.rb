class AddTranslationsToTaxonomies < ActiveRecord::Migration
  def up
    Spree::Taxonomy.create_translation_table!({ :name => :string }, { :migrate_data => true })
  end

  def down
    Spree::Taxonomy.drop_translation_table! :migrate_data => true
  end
end
