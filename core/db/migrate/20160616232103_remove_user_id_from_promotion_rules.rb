class RemoveUserIdFromPromotionRules < ActiveRecord::Migration
  def up
    remove_index :spree_promotion_rules, name: 'index_promotion_rules_on_user_id'
    remove_column :spree_promotion_rules, :user_id
  end

  def down
    add_column :spree_promotion_rules, :user_id, :integer
    add_index :spree_promotion_rules, [:user_id], name: 'index_promotion_rules_on_user_id'
  end
end
