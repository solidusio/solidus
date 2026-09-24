# frozen_string_literal: true

class AddAddressToSpreeStores < ActiveRecord::Migration[7.0]
  def change
    change_table :spree_stores do |t|
      t.references :address, type: :integer, foreign_key: {to_table: :spree_addresses}
    end
  end
end
