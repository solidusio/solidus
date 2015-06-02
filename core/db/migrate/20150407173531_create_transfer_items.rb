class CreateTransferItems < ActiveRecord::Migration
  def change
    create_table :spree_transfer_items do |t|
      t.integer :variant_id, null: false
      t.integer :stock_transfer_id, null: false
      t.integer :expected_quantity, null: false, default: 0
      t.integer :received_quantity, null: false, default: 0
      t.timestamps null: true
    end

    add_index :spree_transfer_items, :stock_transfer_id
    add_index :spree_transfer_items, :variant_id
  end
end
