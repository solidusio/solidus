class CreateStoreShippingMethods < ActiveRecord::Migration
  include Spree::MigrationHelpers

  def change
    unless table_exists?(:spree_store_shipping_methods)
      create_table :spree_store_shipping_methods do |t|
        t.integer :store_id
        t.integer :shipping_method_id

        t.timestamps null: false
      end
    end

    safe_add_index :spree_store_shipping_methods, :store_id
    safe_add_index :spree_store_shipping_methods, :shipping_method_id
  end
end
