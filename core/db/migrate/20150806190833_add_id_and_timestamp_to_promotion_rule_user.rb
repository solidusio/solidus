class AddIdAndTimestampToPromotionRuleUser < ActiveRecord::Migration
  def up
    add_column :spree_promotion_rules_users, :id, :primary_key
    add_column :spree_promotion_rules_users, :created_at, :datetime
    add_column :spree_promotion_rules_users, :updated_at, :datetime
  end

  def down
    remove_column :spree_promotion_rules_users, :updated_at
    remove_column :spree_promotion_rules_users, :created_at
    remove_column :spree_promotion_rules_users, :id
  end
end
