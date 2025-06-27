# frozen_string_literal: true

class AddForeignKeyToSpreeRoleUsers < ActiveRecord::Migration[7.0]
  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned roles/user join records (no corresponding role)" do
    #   Spree::RoleUser.left_joins(:role).where(spree_roles: { id: nil }).delete_all
    # end

    add_foreign_key :spree_roles_users, :spree_roles, column: :role_id, null: false
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
      Rails.logger.warn <<~MSG
        ⚠️ Foreign key constraint failed when adding :spree_roles_users => :spree_roles.
        To fix this:
          1. Uncomment the code that removes orphaned records.
          2. Rerun the migration.
        Offending error: #{e.cause.class} - #{e.cause.message}
      MSG
    end
    raise
  end

  def down
    remove_foreign_key :spree_roles_users, :spree_roles, column: :role_id, null: false
  end
end
