class CreateSpreePromotionRuleRoles < ActiveRecord::Migration
  def change
    create_table :spree_promotion_rule_roles do |t|
      t.references :promotion_rule, index: true, null: false
      t.references :role, index: true, null: false

      t.timestamps null: false
    end
  end
end
