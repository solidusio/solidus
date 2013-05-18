class AddTranslationsToMainModels < ActiveRecord::Migration
  def up
    params = { :name => :string, :description => :text, :meta_description => :string,
               :meta_keywords => :string }
    Spree::Product.create_translation_table!(params, { :migrate_data => true })

    params = { :name => :string, :description => :string }
    Spree::Promotion.create_translation_table!(params, { :migrate_data => true })

    params = { :name => :string, :presentation => :string }
    Spree::OptionType.create_translation_table!(params, { :migrate_data => true })
    Spree::Property.create_translation_table!(params, { :migrate_data => true })

    Spree::Taxonomy.create_translation_table!({ :name => :string }, { :migrate_data => true })

    params = { :name => :string, :description => :text, :meta_title => :string,
               :meta_description => :string, :meta_keywords => :string,
               :permalink => :string }
    Spree::Taxon.create_translation_table!(params, { :migrate_data => true })
  end

  def down
    Spree::Product.drop_translation_table! :migrate_data => true
    Spree::Promotion.drop_translation_table! :migrate_data => true
    Spree::Property.drop_translation_table! :migrate_data => true
    Spree::OptionType.drop_translation_table! :migrate_data => true
    Spree::Taxonomy.drop_translation_table! :migrate_data => true
    Spree::Taxon.drop_translation_table! :migrate_data => true
  end
end
