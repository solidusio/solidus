# frozen_string_literal: true

class AddFkProductsVariantPropertyRules < ActiveRecord::Migration[7.0]
  FOREIGN_KEY_VIOLATION_ERRORS = %w[PG::ForeignKeyViolation Mysql2::Error SQLite3::ConstraintException]

  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned variant property rules (no corresponding product)" do
    #   Spree::VariantPropertyRule.left_joins(:product).where(spree_products: { id: nil }).delete_all
    # end

    add_foreign_key :spree_variant_property_rules, :spree_products, column: :product_id, null: false
  rescue ActiveRecord::StatementInvalid => e
    if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
      say <<~MSG
        ⚠️ Foreign key constraint failed when adding :spree_variant_property_rules => :spree_products.
        To fix this:
          1. Uncomment the code that removes orphaned records.
          2. Rerun the migration.
        Offending error: #{e.cause.class} - #{e.cause.message}
      MSG
    end
    raise
  end

  def down
    remove_foreign_key :spree_variant_property_rules, :spree_products, column: :product_id, null: false
  end
end
