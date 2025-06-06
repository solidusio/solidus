# frozen_string_literal: true

class AddFkProductsVariantPropertyRules < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_variant_property_rules, :spree_products, column: :product_id, null: false
  end
end
