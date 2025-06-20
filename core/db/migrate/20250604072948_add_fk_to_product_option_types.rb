# frozen_string_literal: true

class AddFkToProductOptionTypes < ActiveRecord::Migration[7.0]
  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned product option types (no corresponding product)" do
    #   Spree::ProductOptionType.left_joins(:product).where(spree_products: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_product_option_types, :spree_products, column: :product_id
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_product_option_types => :spree_products.
          To fix this:
            1. Uncomment the code that removes orphaned records.
            2. Rerun the migration.
          Offending error: #{e.cause.class} - #{e.cause.message}
        MSG
      end
      raise
    end

    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned product option types (no corresponding option type)" do
    #   Spree::ProductOptionType.left_joins(:option_type).where(spree_option_types: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_product_option_types, :spree_option_types, column: :option_type_id
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_product_option_types => :spree_option_types.
          To fix this:
            1. Uncomment the code that removes orphaned records.
            2. Rerun the migration.
          Offending error: #{e.cause.class} - #{e.cause.message}
        MSG
      end
      raise
    end
  end

  def down
    remove_foreign_key :spree_product_option_types, :spree_products, column: :product_id
    remove_foreign_key :spree_product_option_types, :spree_option_types, column: :option_type_id
  end
end
