class AddSpreeUserAddresses < ActiveRecord::Migration
  def change
    create_table :spree_user_addresses do |t|
      t.integer :user_id, null: false
      t.integer :address_id, null: false
      t.boolean :default, default: false
      t.boolean :archived, default: false
      t.timestamps null: false
    end

    add_index :spree_user_addresses, :user_id
    add_index :spree_user_addresses, :address_id
    add_index :spree_user_addresses, [:user_id, :address_id], unique: true
  end
end
