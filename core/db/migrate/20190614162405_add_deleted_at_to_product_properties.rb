# frozen_string_literal: true

class AddDeletedAtToProductProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_product_properties, :deleted_at, :datetime
    add_index :spree_product_properties, :deleted_at
  end
end
