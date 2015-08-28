class ConvertHabtmToHmtForTaxonsPromotionRules < ActiveRecord::Migration
  def up
    add_column :spree_taxons_promotion_rules, :created_at, :datetime
    add_column :spree_taxons_promotion_rules, :updated_at, :datetime

    rename_table :spree_taxons_promotion_rules, :spree_promotion_rule_taxons
  end

  def down
    rename_table :spree_promotion_rule_taxons, :spree_taxons_promotion_rules

    remove_column :spree_taxons_promotion_rules, :created_at, :datetime
    remove_column :spree_taxons_promotion_rules, :updated_at, :datetime
  end
end
