# frozen_string_literal: true

class AddAmountRemainingToStoreCreditEvents < ActiveRecord::Migration[5.0]
  def change
    add_column :spree_store_credit_events, :amount_remaining, :decimal, precision: 8, scale: 2, default: 0.0, null: false
  end
end
