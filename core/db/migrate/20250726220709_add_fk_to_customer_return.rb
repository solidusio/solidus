# frozent_string_literal: true
#
class AddFkToCustomerReturn < ActiveRecord::Migration[7.0]
  FOREIGN_KEY_VIOLATION_ERRORS = %w[PG::ForeignKeyViolation Mysql2::Error SQLite3::ConstraintException]

  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing invalid adjustment reason IDs from adjustments table" do
    #   Spree::CustomerReturn.where.not(stock_location_id: nil).left_joins(:stock_location).where(spree_stock_locations: { id: nil }).delete_all
    # end

    add_foreign_key :spree_customer_returns, :spree_stock_locations, column: :stock_location_id, null: false, on_delete: :restrict
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
      say <<~MSG
        ⚠️ Foreign key constraint failed when adding :spree_customer_returns => :spree_stock_locations.
        To fix this:
          1. Uncomment the code that removes invalid adjustment reason IDs from the spree_customer_returns table.
          2. Rerun the migration.
        Offending error: #{e.cause.class} - #{e.cause.message}
      MSG
    end
    raise
  end

  def down
    remove_foreign_key :spree_customer_returns, :spree_stock_locations, column: :stock_location_id, null: false, on_delete: :restrict
  end
end
