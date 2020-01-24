# frozen_string_literal: true

class AddMergedToOrderId < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_orders, :merged_to_order_id, :integer, limit: 4
    add_foreign_key :spree_orders, :spree_orders, column: :merged_to_order_id
  end
end
