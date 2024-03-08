# frozen_string_literal: true

class CreateSpreeRolesPermissions < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_role_permissions do |t|
      t.references :role
      t.references :permission_set
      t.timestamps
    end
  end
end
