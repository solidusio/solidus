class AddTranslationsToOptionValue < ActiveRecord::Migration
  def up
    params = { :name => :string, :presentation => :string }
    Spree::OptionValue.create_translation_table!(params, { :migrate_data => true })
  end
  
  def down
    Spree::OptionValue.drop_translation_table! :migrate_data => true
  end
end