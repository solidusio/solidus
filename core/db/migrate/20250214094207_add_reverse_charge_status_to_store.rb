# frozen_string_literal: true

class AddReverseChargeStatusToStore < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_stores, :reverse_charge_status, :integer, default: 0, null: false,
                comment: "Enum values: 0 = disabled, 1 = enabled, 2 = not_validated"
  end
end
