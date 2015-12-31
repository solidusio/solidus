class AddTimestampsToSolidusRolesUsers < ActiveRecord::Migration
  def change
    add_column :solidus_roles_users, :id, :primary_key
    add_column :solidus_roles_users, :created_at, :datetime
    add_column :solidus_roles_users, :updated_at, :datetime
  end
end
