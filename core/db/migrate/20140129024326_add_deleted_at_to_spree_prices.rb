class AddDeletedAtToSolidusPrices < ActiveRecord::Migration
  def change
    add_column :solidus_prices, :deleted_at, :datetime
  end
end
