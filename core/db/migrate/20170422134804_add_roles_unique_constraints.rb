# frozen_string_literal: true

require "spree/migration"

class AddRolesUniqueConstraints < Spree::Migration
  def change
    add_index :spree_roles, :name, unique: true
    add_index :spree_roles_users, [:user_id, :role_id], unique: true
  end
end
