class RenameSpreeRolesUsersToSpreeRoleUsers < ActiveRecord::Migration
  def change
    rename_table :spree_roles_users, :spree_role_users
  end
end
