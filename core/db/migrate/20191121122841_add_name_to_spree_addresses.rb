# frozen_string_literal: true

class AddNameToSpreeAddresses < ActiveRecord::Migration[5.1]
  def change
    add_column :spree_addresses, :name, :string
  end
end
