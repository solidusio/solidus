class RenamePromotionRulesToConditions < ActiveRecord::Migration[7.1]
  def change
    rename_table :friendly_promotion_rules, :friendly_conditions
    rename_table :friendly_promotion_rules_stores, :friendly_condition_stores
    rename_table :friendly_promotion_rules_taxons, :friendly_condition_taxons
    rename_table :friendly_promotion_rules_users, :friendly_condition_users
    rename_table :friendly_products_promotion_rules, :friendly_condition_products
    rename_column :friendly_condition_stores, :promotion_rule_id, :condition_id
    rename_column :friendly_condition_taxons, :promotion_rule_id, :condition_id
    rename_column :friendly_condition_users, :promotion_rule_id, :condition_id
    rename_column :friendly_condition_products, :promotion_rule_id, :condition_id
    sql = <<~SQL
      UPDATE friendly_conditions
      SET type = REPLACE(type, 'SolidusFriendlyPromotions::Rules', 'SolidusFriendlyPromotions::Conditions')
    SQL

    execute(sql)
  end
end
