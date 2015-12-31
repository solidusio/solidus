class AddForeignKeysForProductPromotionRules < ActiveRecord::Migration
  def change
    add_foreign_key :solidus_product_promotion_rules, :solidus_products,
                    column: :product_id

    add_foreign_key :solidus_product_promotion_rules, :solidus_promotion_rules,
                    column: :promotion_rule_id
  end
end
