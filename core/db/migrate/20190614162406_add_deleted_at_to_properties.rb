# frozen_string_literal: true

class AddDeletedAtToProperties < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_properties, :deleted_at, :datetime
    add_index :spree_properties, :deleted_at
  end
end
