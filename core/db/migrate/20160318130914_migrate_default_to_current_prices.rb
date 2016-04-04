class MigrateDefaultToCurrentPrices < ActiveRecord::Migration
  def up
    execute(<<-SQL)
      UPDATE spree_prices
      SET valid_from = '#{Time.current.to_s(:db)}'
      WHERE is_default = #{ActiveRecord::Base.connection.quoted_true}
    SQL

    # Prices are saved with Time.current as valid_from if not set.
    # This sets all non-default prices to their variant's `updated_at` date.
    # This is not entirely accurate, but we can't do better as variants do not
    # have a created_at timestamp.
    execute(<<-SQL)
      UPDATE spree_prices
      SET valid_from = (
        SELECT updated_at FROM spree_variants WHERE spree_prices.variant_id = spree_variants.id
      )
      WHERE is_default = #{ActiveRecord::Base.connection.quoted_false}
    SQL

    remove_column :spree_prices, :is_default, :boolean
  end

  def down
    add_column :spree_prices, :is_default, :boolean

    execute(<<-SQL)
      UPDATE spree_prices
      SET is_default = #{ActiveRecord::Base.connection.quoted_true}
      WHERE valid_from <= '#{Time.current.to_s(:db)}' ORDER BY valid_from DESC LIMIT 1
    SQL
  end
end
