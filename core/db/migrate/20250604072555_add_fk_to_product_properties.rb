# frozen_string_literal: true

class AddFkToProductProperties < ActiveRecord::Migration[7.0]
  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned product properties (no corresponding product)" do
    #   Spree::ProductProperty.left_joins(:product).where(spree_products: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_product_properties, :spree_products, column: :product_id, null: false
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_product_properties => :spree_products.
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
    # say_with_time "Removing orphaned product properties (no corresponding property)" do
    #   Spree::ProductProperty.left_joins(:property).where(spree_properties: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_product_properties, :spree_properties, column: :property_id, null: false
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_product_properties => :spree_properties.
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
    remove_foreign_key :spree_product_properties, :spree_products, column: :product_id, null: false
    remove_foreign_key :spree_product_properties, :spree_properties, column: :property_id, null: false
  end
end
