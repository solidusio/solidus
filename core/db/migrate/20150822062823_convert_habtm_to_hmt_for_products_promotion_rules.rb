class ConvertHabtmToHmtForProductsPromotionRules < ActiveRecord::Migration
  def up
    add_column :spree_products_promotion_rules, :id, :primary_key
    add_column :spree_products_promotion_rules, :created_at, :datetime
    add_column :spree_products_promotion_rules, :updated_at, :datetime

    rename_table :spree_products_promotion_rules, :spree_product_promotion_rules
  end

  def down
    rename_table :spree_product_promotion_rules, :spree_products_promotion_rules

    remove_column :spree_products_promotion_rules, :id, :primary_key
    remove_column :spree_products_promotion_rules, :created_at, :datetime
    remove_column :spree_products_promotion_rules, :updated_at, :datetime
  end
end
