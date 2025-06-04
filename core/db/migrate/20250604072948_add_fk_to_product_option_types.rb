# frozen_string_literal: true

class AddFkToProductOptionTypes < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_product_option_types, :spree_products, column: :product_id
    add_foreign_key :spree_product_option_types, :spree_option_types, column: :option_type_id
  end
end
