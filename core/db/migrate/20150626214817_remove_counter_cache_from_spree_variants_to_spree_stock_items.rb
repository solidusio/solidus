class RemoveCounterCacheFromSolidusVariantsToSolidusStockItems < ActiveRecord::Migration
  def up
    if column_exists?(:solidus_variants, :stock_items_count)
      remove_column :solidus_variants, :stock_items_count
    end
  end

  def down
  end
end
