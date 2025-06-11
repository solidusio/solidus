# frozen_string_literal: true

class AddShippingCategoryForeignKeys < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_products, :spree_shipping_categories, column: :shipping_category_id, null: false
    add_foreign_key :spree_shipping_method_categories, :spree_shipping_methods, column: :shipping_method_id, null: false
    add_foreign_key :spree_shipping_method_categories, :spree_shipping_categories, column: :shipping_category_id, null: false
  end
end
