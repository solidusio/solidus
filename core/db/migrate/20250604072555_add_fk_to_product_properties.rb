# frozen_string_literal: true

class AddFkToProductProperties < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_product_properties, :spree_products, column: :product_id, null: false
    add_foreign_key :spree_product_properties, :spree_properties, column: :property_id, null: false
  end
end
