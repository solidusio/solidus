class AddSaleToSpreePromotions < ActiveRecord::Migration
  def change
    add_column :spree_promotions, :sale, :boolean, default: false
    add_index :spree_promotions, :sale
  end
end
