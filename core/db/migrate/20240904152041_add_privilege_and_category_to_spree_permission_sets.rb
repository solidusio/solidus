class AddPrivilegeAndCategoryToSpreePermissionSets < ActiveRecord::Migration[7.0]
  def change
    add_column :spree_permission_sets, :privilege, :string
    add_column :spree_permission_sets, :category, :string
  end
end
