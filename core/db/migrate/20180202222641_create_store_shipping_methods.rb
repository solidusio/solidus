class CreateStoreShippingMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_store_shipping_methods do |t|
      t.references :store, foreign_key: { to_table: "spree_stores" }
      t.references :shipping_method, foreign_key: { to_table: "spree_shipping_methods" }

      t.timestamps
    end
  end
end
