class ConvertHabtmToHmtForExistingTables < ActiveRecord::Migration
  def up
    rename_table :spree_products_taxons, :spree_classifications
    rename_table :spree_roles_users, :spree_role_users
    rename_table :spree_promotion_rules_users, :spree_promotion_rule_users
    rename_table :spree_orders_promotions, :spree_order_promotions
  end

  def down
    rename_table :spree_classifications, :spree_products_taxons
    rename_table :spree_role_users, :spree_roles_users
    rename_table :spree_promotion_rule_users, :spree_promotion_rules_users
    rename_table :spree_order_promotions, :spree_orders_promotions
  end
end
