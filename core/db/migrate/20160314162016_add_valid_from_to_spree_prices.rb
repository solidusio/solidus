class AddValidFromToSpreePrices < ActiveRecord::Migration
  def change
    add_column :spree_prices, :valid_from, :datetime
  end
end
