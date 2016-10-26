class CreateSpreeStoreCreditLedgerEntry < ActiveRecord::Migration[5.0]
  def change
    create_table :spree_store_credit_ledger_entries do |t|
      t.decimal :amount, precision: 8, scale: 2, default: 0.0, null: false
      t.references :store_credit, index: true
      index_name = "idx_spree_sc_ledger_entries_on_orig_type_and_orig_id"
      t.references :originator, polymorphic: true, index: { name: index_name }
      t.boolean :liability, default: true, null: false
      t.timestamps null: false
    end
  end
end
