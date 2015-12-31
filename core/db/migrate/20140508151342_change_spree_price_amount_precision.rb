class ChangeSpreePriceAmountPrecision < ActiveRecord::Migration
  def change
    change_column :solidus_prices, :amount,  :decimal, :precision => 10, :scale => 2
    change_column :solidus_line_items, :price,  :decimal, :precision => 10, :scale => 2
    change_column :solidus_line_items, :cost_price,  :decimal, :precision => 10, :scale => 2
    change_column :solidus_variants, :cost_price, :decimal, :precision => 10, :scale => 2
  end
end
