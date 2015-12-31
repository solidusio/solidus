class AddCostPriceToLineItem < ActiveRecord::Migration
  def change
    add_column :solidus_line_items, :cost_price, :decimal, :precision => 8, :scale => 2
  end
end
