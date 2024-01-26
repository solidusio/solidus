class AddOrderPromotionsForeignKey < ActiveRecord::Migration[7.0]
  def up
    Spree::OrderPromotion.left_joins(:order).where(spree_orders: { id: nil }).delete_all
    add_foreign_key :spree_orders_promotions, :spree_orders, column: :order_id, validate: false, on_delete: :cascade
  end

  def down
    remove_foreign_key :spree_orders_promotions, :spree_orders
  end
end
