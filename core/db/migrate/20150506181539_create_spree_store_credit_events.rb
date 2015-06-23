class CreateSpreeStoreCreditEvents < ActiveRecord::Migration
  def change
    create_table :spree_store_credit_events do |t|
      t.integer :store_credit_id,    null: false
      t.string  :action,             null: false
      t.decimal :amount,             precision: 8,  scale: 2
      t.decimal :user_total_amount,  precision: 8,  scale: 2, default: 0.0, null: false
      t.string  :authorization_code, null: false
      t.datetime :deleted_at
      t.references :originator, polymorphic: true
      t.timestamps null: true
    end

    add_index :spree_store_credit_events, :store_credit_id
    add_index :spree_store_credit_events, :deleted_at
  end
end
