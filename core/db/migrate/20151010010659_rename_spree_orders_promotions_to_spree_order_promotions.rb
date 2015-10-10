class RenameSpreeOrdersPromotionsToSpreeOrderPromotions < ActiveRecord::Migration
  def change
    rename_table :spree_orders_promotions, :spree_order_promotions
  end
end
