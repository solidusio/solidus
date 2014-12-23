class AddTranslationsToProductPermalink < ActiveRecord::Migration
  def up
    if column_exists?(:spree_products, :permalink)
      fields = { permalink: :string }
    else
      fields = { slug: :string }
    end
    Spree::Product.add_translation_fields!(fields, { migrate_data: true })
  end

  def down
  end
end
