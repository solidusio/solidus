class AddInitialPriceToLineItems < ActiveRecord::Migration
  def change
    add_column :spree_line_items, :initial_price, :decimal, precision: 8, scale: 2
  end
end
