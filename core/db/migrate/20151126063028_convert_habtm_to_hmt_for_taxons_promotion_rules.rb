class ConvertHabtmToHmtForTaxonsPromotionRules < ActiveRecord::Migration
  def up
    add_column :solidus_taxons_promotion_rules, :created_at, :datetime
    add_column :solidus_taxons_promotion_rules, :updated_at, :datetime

    rename_table :solidus_taxons_promotion_rules, :solidus_promotion_rule_taxons
  end

  def down
    rename_table :solidus_promotion_rule_taxons, :solidus_taxons_promotion_rules

    remove_column :solidus_taxons_promotion_rules, :created_at, :datetime
    remove_column :solidus_taxons_promotion_rules, :updated_at, :datetime
  end
end
