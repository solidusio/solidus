class CreateStoreShippingMethods < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_store_shipping_methods do |t|
      t.references :store, null: false
      t.references :shipping_method, null: false

      t.timestamps
    end
  end
end
