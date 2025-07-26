# frozen_string_literal: true

class AddStateForeignKeys < ActiveRecord::Migration[7.0]
  FOREIGN_KEY_VIOLATION_ERRORS = %w[PG::ForeignKeyViolation Mysql2::Error SQLite3::ConstraintException]

  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Resetting state IDs on addresses where the state record is no longer present" do
    #   Spree::Address.where.not(state_id: nil).left_joins(:state).where(spree_states: { id: nil }).update_all(state_id: nil)
    # end

    add_foreign_key :spree_addresses, :spree_states, column: :state_id, null: true, on_delete: :restrict
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
      say <<~MSG
        ⚠️ Foreign key constraint failed when adding :spree_addresses => :spree_states.
        To fix this:
          1. Uncomment the code that removes orphaned records.
          2. Rerun the migration.
        Offending error: #{e.cause.class} - #{e.cause.message}
      MSG
    end
    raise
  end

  def down
    remove_foreign_key :spree_addresses, :spree_states, column: :state_id, null: true, on_delete: :restrict
  end
end
