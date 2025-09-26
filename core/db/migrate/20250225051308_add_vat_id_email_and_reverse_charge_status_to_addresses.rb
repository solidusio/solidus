# frozen_string_literal: true

class AddVatIdEmailAndReverseChargeStatusToAddresses < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_addresses, :vat_id, :string
    add_column :spree_addresses, :email, :string
    add_column :spree_addresses, :reverse_charge_status, :integer, default: 0, null: false,
      comment: "Enum values: 0 = disabled, 1 = enabled, 2 = not_validated"
  end
end
