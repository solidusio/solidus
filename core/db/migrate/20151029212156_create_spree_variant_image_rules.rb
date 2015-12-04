class CreateSpreeVariantImageRules < ActiveRecord::Migration
  def change
    create_table :spree_variant_image_rules do |t|
      t.references :product
      t.timestamps null: false
    end
    add_index :spree_variant_image_rules, :product_id
  end
end
