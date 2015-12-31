class ConvertHabtmToHmtForProductsPromotionRules < ActiveRecord::Migration
  def up
    add_column :solidus_products_promotion_rules, :id, :primary_key
    add_column :solidus_products_promotion_rules, :created_at, :datetime
    add_column :solidus_products_promotion_rules, :updated_at, :datetime

    rename_table :solidus_products_promotion_rules, :solidus_product_promotion_rules
  end

  def down
    rename_table :solidus_product_promotion_rules, :solidus_products_promotion_rules

    remove_column :solidus_products_promotion_rules, :id, :primary_key
    remove_column :solidus_products_promotion_rules, :created_at, :datetime
    remove_column :solidus_products_promotion_rules, :updated_at, :datetime
  end
end
