# frozen_string_literal: true

class AddAdjustmentReasonForeignKeys < ActiveRecord::Migration[7.0]
  FOREIGN_KEY_VIOLATION_ERRORS = %w[PG::ForeignKeyViolation Mysql2::Error SQLite3::ConstraintException]

  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing invalid adjustment reason IDs from adjustments table" do
    #   Spree::Adjustment.where.not(adjustment_reason_id: nil).left_joins(:adjustment_reason).where(spree_adjustment_reasons: { id: nil }).update_all(adjustment_reason_id: nil)
    # end

    add_foreign_key :spree_adjustments, :spree_adjustment_reasons, column: :adjustment_reason_id, null: true, on_delete: :restrict
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
      Rails.logger.warn <<~MSG
        ⚠️ Foreign key constraint failed when adding :spree_adjustments => :spree_adjustment_reasons.
        To fix this:
          1. Uncomment the code that removes invalid adjustment reason IDs from the spree_adjustments table.
          2. Rerun the migration.
        Offending error: #{e.cause.class} - #{e.cause.message}
      MSG
    end
    raise
  end

  def down
    remove_foreign_key :spree_adjustments, :spree_adjustment_reasons, column: :adjustment_reason_id, null: true, on_delete: :restrict
  end
end
