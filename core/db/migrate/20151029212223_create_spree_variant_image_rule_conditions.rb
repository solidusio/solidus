class CreateSpreeVariantImageRuleConditions < ActiveRecord::Migration
  def change
    create_table :spree_variant_image_rule_conditions do |t|
      t.references :option_value
      t.references :variant_image_rule
      t.timestamps null: false
    end

    add_index :spree_variant_image_rule_conditions, [:variant_image_rule_id, :option_value_id], name: "index_spree_variant_img_rule_conditions_on_rule_and_optval"
  end
end
