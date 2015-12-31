class CreateSpreeReimbursements < ActiveRecord::Migration
  def change
    create_table :solidus_reimbursements do |t|
      t.string :number
      t.string :reimbursement_status
      t.integer :customer_return_id
      t.integer :order_id
      t.decimal :total, precision: 10, scale: 2

      t.timestamps null: true
    end

    add_index :solidus_reimbursements, :customer_return_id
    add_index :solidus_reimbursements, :order_id

    remove_column :solidus_refunds, :customer_return_id, :integer
    add_column :solidus_refunds, :reimbursement_id, :integer

    add_column :solidus_return_items, :reimbursement_id, :integer
  end
end
