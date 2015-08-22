class ConvertHabtmToHmtForProductsPromotionRules < ActiveRecord::Migration
  def up
    add_column :spree_products_promotion_rules, :id, :primary_key if add_id
    add_column :spree_products_promotion_rules, :created_at, :datetime
    add_column :spree_products_promotion_rules, :updated_at, :datetime

    rename_table :spree_products_promotion_rules, :spree_product_promotion_rules
  end

  def down
    remove_column :spree_products_promotion_rules, :id, :primary_key if add_id
    remove_column :spree_products_promotion_rules, :created_at, :datetime
    remove_column :spree_products_promotion_rules, :updated_at, :datetime

    rename_table :spree_product_promotion_rules, :spree_products_promotion_rules
  end
end
