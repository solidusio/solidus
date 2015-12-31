class AddIdAndTimestampToPromotionRuleUser < ActiveRecord::Migration
  def up
    add_column :solidus_promotion_rules_users, :id, :primary_key
    add_column :solidus_promotion_rules_users, :created_at, :datetime
    add_column :solidus_promotion_rules_users, :updated_at, :datetime
  end

  def down
    remove_column :solidus_promotion_rules_users, :updated_at
    remove_column :solidus_promotion_rules_users, :created_at
    remove_column :solidus_promotion_rules_users, :id
  end
end
