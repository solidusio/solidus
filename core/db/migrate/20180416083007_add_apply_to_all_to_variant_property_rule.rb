# frozen_string_literal: true

class AddApplyToAllToVariantPropertyRule < ActiveRecord::Migration[5.1]
  def up
    add_column :spree_variant_property_rules, :apply_to_all, :boolean, default: false, null: false
    change_column :spree_variant_property_rules, :apply_to_all, :boolean, default: true
  end

  def down
    remove_column :spree_variant_property_rules, :apply_to_all
  end
end
