# frozen_string_literal: true

class CreateStoreShippingMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_store_shipping_methods do |t|
      t.references :store, null: false
      t.references :shipping_method, null: false

      t.timestamps precision: 6
    end
  end
end
