class RemoveIsDefaultFromPrices < ActiveRecord::Migration
  def change
    remove_column :spree_prices, :is_default, :boolean, default: true
  end
end
