# frozen_string_literal: true

class CreateSpreeSettlements < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_settlements do |t|
      t.decimal :amount, precision: 12, scale: 4, default: "0.0", null: false
      t.decimal :included_tax_total, precision: 12, scale: 4, default: "0.0", null: false
      t.decimal :additional_tax_total, precision: 12, scale: 4, default: "0.0", null: false
      t.string :acceptance_status
      t.text :acceptance_status_errors

      t.references :reimbursement, index: false
      t.references :reimbursement_type, index: false
      t.references :shipment

      t.timestamps precision: 6
    end
  end
end
