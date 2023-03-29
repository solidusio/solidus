# frozen_string_literal: true

require "spree/migration"

class AddApplyToAllToVariantPropertyRule < Spree::Migration
  def change
    add_column :spree_variant_property_rules, :apply_to_all, :boolean, default: false, null: false
    change_column :spree_variant_property_rules, :apply_to_all, :boolean, default: true
  end

  def down
    remove_column :spree_variant_property_rules, :apply_to_all
  end
end
