# frozen_string_literal: true

class AddAddressbookForeignKey < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :spree_user_addresses, :spree_addresses, column: :address_id, null: false
  end
end
