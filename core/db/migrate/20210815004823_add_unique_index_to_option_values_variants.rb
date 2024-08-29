# frozen_string_literal: true

class AddUniqueIndexToOptionValuesVariants < ActiveRecord::Migration[5.2]
  def up
    remove_index :spree_option_values_variants, [:variant_id, :option_value_id]
    add_index :spree_option_values_variants, [:variant_id, :option_value_id],
      name: "index_option_values_variants_on_variant_id_and_option_value_id",
      unique: true
  end

  def down
    remove_index :spree_option_values_variants, [:variant_id, :option_value_id]
    add_index :spree_option_values_variants, [:variant_id, :option_value_id],
      name: "index_option_values_variants_on_variant_id_and_option_value_id"
  end
end
