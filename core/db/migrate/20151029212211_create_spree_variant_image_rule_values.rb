class CreateSpreeVariantImageRuleValues < ActiveRecord::Migration
  def change
    create_table :spree_variant_image_rule_values do |t|
      t.references :image
      t.references :variant_image_rule
      t.integer    :position, default: 0
    end

    add_index :spree_variant_image_rule_values, :image_id
    add_index :spree_variant_image_rule_values, :variant_image_rule_id, name: "index_spree_variant_image_rule_values_on_rule"
  end
end
