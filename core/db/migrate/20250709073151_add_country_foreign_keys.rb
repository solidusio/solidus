# frozen_string_literal: true

class AddCountryForeignKeys < ActiveRecord::Migration[7.0]
  def up
    # Uncomment the following code to remove orphaned records if this migration fails
    #
    # say_with_time "Removing orphaned states (no corresponding country)" do
    #   Spree::State.left_joins(:country).where(spree_countries: { id: nil }).delete_all
    # end

    begin
      add_foreign_key :spree_states, :spree_countries, column: :country_id, null: false, on_delete: :cascade
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_states => :spree_countries.
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
    # say_with_time "Updating orphaned addresses (no corresponding country) to use default country" do
    #   Spree::Address.left_joins(:country).where(spree_countries: { id: nil }).update_all(country: Spree::Country.default)
    # end

    begin
      add_foreign_key :spree_addresses, :spree_countries, column: :country_id, null: false, on_delete: :restrict
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_addresses => :spree_countries.
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
    # say_with_time "Deleting orphaned prices (country ID without corresponding country)" do
    #   Spree::Price.where.not(country_iso: nil).left_joins(:country).where(spree_countries: { iso: nil }).update_all(country_iso: Spree::Config.default_country_iso)
    # end

    begin
      add_foreign_key :spree_prices, :spree_countries, column: :country_iso, primary_key: :iso, null: true, on_delete: :restrict
    rescue ActiveRecord::StatementInvalid => e
      if e.cause.is_a?(PG::ForeignKeyViolation) || e.cause.is_a?(Mysql2::Error) || e.cause.is_a?(SQLite3::ConstraintException)
        Rails.logger.warn <<~MSG
          ⚠️ Foreign key constraint failed when adding :spree_prices => :spree_countries.
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
    remove_foreign_key :spree_states, :spree_countries, column: :country_id, null: false, on_delete: :cascade
    remove_foreign_key :spree_addresses, :spree_countries, column: :country_id, null: false, on_delete: :restrict
    remove_foreign_key :spree_prices, :spree_countries, column: :country_id, null: true, on_delete: :restrict
  end
end
