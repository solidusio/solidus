class CreateSpreeRolesPermissionsInCore < ActiveRecord::Migration[7.0]
  def change
    create_table :spree_role_permissions, if_not_exists: true do |t|
      t.references :role
      t.references :permission_set
      t.timestamps null: false
    end
  end
end
