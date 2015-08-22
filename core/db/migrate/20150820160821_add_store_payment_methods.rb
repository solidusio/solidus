class AddStorePaymentMethods < ActiveRecord::Migration
  def change
    create_table :spree_store_payment_methods do |t|
      t.references :store, null: false, index: true
      t.references :payment_method, null: false, index: true

      t.timestamps null: false
    end
  end
end
