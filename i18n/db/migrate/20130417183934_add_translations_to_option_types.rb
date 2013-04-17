class AddTranslationsToOptionTypes < ActiveRecord::Migration
  def up
    params = { :name => :string, :presentation => :string }
    Spree::OptionType.create_translation_table!(params, { :migrate_data => true })
  end

  def down
    Spree::OptionType.drop_translation_table! :migrate_data => true
  end
end
