# frozen_string_literal: true

class PropertyRulesApplyToAll < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_variant_property_rules, :apply_to_all, :boolean, default: false
  end
end
