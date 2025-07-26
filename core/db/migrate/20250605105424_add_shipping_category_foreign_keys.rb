# frozen_string_literal: true

class AddShippingCategoryForeignKeys < ActiveRecord::Migration[7.0]
  FOREIGN_KEY_VIOLATION_ERRORS = %w[PG::ForeignKeyViolation Mysql2::Error SQLite3::ConstraintException]

  def change
    # Uncomment the following code to remove orphaned records if the following code fails
    #
    # say_with_time "Removing orphaned products (no corresponding shipping category)" do
    #   Spree::Product.left_joins(:shipping_category).where(spree_shipping_category: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_products, :spree_shipping_categories, column: :shipping_category_id, null: false
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
        say <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_products => :spree_shipping_categories.
          To fix this:
            1. Uncomment the code that removes orphaned records.
            2. Rerun the migration.
          Offending error: #{e.cause.class} - #{e.cause.message}
        MSG
      end
      raise
    end

    # Uncomment the following code to remove orphaned records if the following code fails
    #
    # say_with_time "Removing orphaned shipping method categories (no corresponding shipping category)" do
    #   Spree::ShippingMethodCategory.left_joins(:shipping_category).where(spree_shipping_category: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_shipping_method_categories, :spree_shipping_methods, column: :shipping_method_id, null: false
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
        say <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_shipping_method_categories => :spree_shipping_methods.
          To fix this:
            1. Uncomment the code that removes orphaned records.
            2. Rerun the migration.
          Offending error: #{e.cause.class} - #{e.cause.message}
        MSG
      end
      raise
    end

    # Uncomment the following code to remove orphaned records if the following code fails
    #
    # say_with_time "Removing orphaned shipping method categories (no corresponding shipping method)" do
    #   Spree::ShippingMethodCategory.left_joins(:shipping_method).where(spree_shipping_method: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_shipping_method_categories, :spree_shipping_categories, column: :shipping_category_id, null: false
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.class.name.in?(FOREIGN_KEY_VIOLATION_ERRORS)
        say <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_shipping_method_categories => :spree_shipping_categories.
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
    remove_foreign_key :spree_products, :spree_shipping_categories, column: :shipping_category_id, null: false
    remove_foreign_key :spree_shipping_method_categories, :spree_shipping_methods, column: :shipping_method_id, null: false
    remove_foreign_key :spree_shipping_method_categories, :spree_shipping_categories, column: :shipping_category_id, null: false
  end
end
