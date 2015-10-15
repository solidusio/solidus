class AddForeignKeysForProductPromotionRules < ActiveRecord::Migration
  def change
    add_foreign_key :spree_product_promotion_rules, :spree_products,
                    column: :product_id, on_delete: :cascade

    add_foreign_key :spree_product_promotion_rules, :spree_promotion_rules,
                    column: :promotion_rule_id, on_delete: :cascade
  end
end
