class AddTranslationsToProductPermalink < ActiveRecord::Migration
  def up
    fields = { :permalink => :string }
    Spree::Product.add_translation_fields!(fields, { :migrate_data => true })
  end

  def down
  end
end
