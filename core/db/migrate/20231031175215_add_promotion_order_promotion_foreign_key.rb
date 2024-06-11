class AddPromotionOrderPromotionForeignKey < ActiveRecord::Migration[7.0]
  def up
    Spree::OrderPromotion.left_joins(:promotion).where(spree_promotions: { id: nil }).delete_all
    add_foreign_key :spree_orders_promotions, :spree_promotions, column: :promotion_id, on_delete: :cascade
  end

  def down
    remove_foreign_key :spree_orders_promotions, :spree_promotions
  end
end
