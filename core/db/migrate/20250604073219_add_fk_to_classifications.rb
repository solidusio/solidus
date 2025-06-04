# frozen_string_literal: true

class AddFkToClassifications < ActiveRecord::Migration[7.0]
  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned classifications (no corresponding product)" do
    #   Spree::Classification.left_joins(:product).where(spree_products: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_products_taxons, :spree_products, column: :product_id
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_products_taxons => :spree_products.
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
    # say_with_time "Removing orphaned classifications (no corresponding taxon)" do
    #   Spree::Classification.left_joins(:taxon).where(spree_taxons: { id: nil }).delete_all
    # end
    begin
      add_foreign_key :spree_products_taxons, :spree_taxons, column: :taxon_id
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_products_taxons => :spree_taxons.
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
    remove_foreign_key :spree_products_taxons, :spree_products, column: :product_id
    remove_foreign_key :spree_products_taxons, :spree_taxons, column: :taxon_id
  end
end
