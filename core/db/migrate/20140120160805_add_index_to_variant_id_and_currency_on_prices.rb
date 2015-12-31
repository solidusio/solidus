class AddIndexToVariantIdAndCurrencyOnPrices < ActiveRecord::Migration
  def change
    add_index :solidus_prices, [:variant_id, :currency]
  end
end
