class CreateFriendlyOrderPromotions < ActiveRecord::Migration[7.0]
  def change
    create_table :friendly_order_promotions do |t|
      t.references :order, type: :integer, index: true, null: false, foreign_key: { to_table: :spree_orders }
      t.references :promotion, index: true, null: false, foreign_key: { to_table: :friendly_promotions }
      t.references :promotion_code, index: true, null: true, foreign_key: { to_table: :friendly_promotion_codes }

      t.timestamps
    end
  end
end
