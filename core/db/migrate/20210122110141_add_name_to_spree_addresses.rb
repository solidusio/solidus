# frozen_string_literal: true

require "spree/migration"

class AddNameToSpreeAddresses < Spree::Migration
  def up
    add_column :spree_addresses, :name, :string
    add_index :spree_addresses, :name
  end

  def down
    remove_index :spree_addresses, :name
    remove_column :spree_addresses, :name
  end
end
