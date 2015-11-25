class RenameSpreePromotionRulesUsersToSpreePromotionRuleUsers < ActiveRecord::Migration
  def change
    rename_table :spree_promotion_rules_users, :spree_promotion_rule_users
  end
end
