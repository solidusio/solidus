class CreateVariantPropertiesAndRules < ActiveRecord::Migration
  def change
    create_table :spree_variant_property_rules do |t|
      t.references :product
      t.timestamps null: false
    end

    add_index :spree_variant_property_rules, :product_id

    create_table :spree_variant_property_rule_conditions do |t|
      t.references :option_value
      t.references :variant_property_rule
      t.timestamps null: false
    end

    add_index :spree_variant_property_rule_conditions, [:variant_property_rule_id, :option_value_id], name: "index_spree_variant_prop_rule_conditions_on_rule_and_optval"

    create_table :spree_variant_property_rule_values do |t|
      t.text       :value
      t.integer    :position, default: 0
      t.references :property
      t.references :variant_property_rule
    end

    add_index :spree_variant_property_rule_values, :property_id
    add_index :spree_variant_property_rule_values, :variant_property_rule_id, name: "index_spree_variant_property_rule_values_on_rule"
  end
end
