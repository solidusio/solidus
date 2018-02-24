class CreatePromotionRuleStores < ActiveRecord::Migration[5.1]
  def change
    create_table :spree_promotion_rules_stores do |t|
      t.references :store, foreign_key: { to_table: "spree_stores" }
      t.references :promotion_rule, foreign_key: { to_table: "spree_promotion_rules" }

      t.timestamps
    end
  end
end
