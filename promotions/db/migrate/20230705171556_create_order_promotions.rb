class CreateOrderPromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :solidus_promotions_order_promotions do |t|
      t.references :order, type: :integer, index: true, null: false, foreign_key: { to_table: :spree_orders }
      t.references :promotion, index: true, null: false, foreign_key: { to_table: :solidus_promotions_promotions }
      t.references :promotion_code, index: true, null: true, foreign_key: { to_table: :solidus_promotions_promotion_codes }

      t.timestamps
    end
  end
end
